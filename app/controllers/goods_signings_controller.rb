class GoodsSigningsController < ApplicationController
  include MineCheckHelper
  include StatementBaseActions
  include CurrentUserHelper

  before_action :set_goods_signing, only: [:show, :update, :signing]
  before_action :authorize_provident_fund, only: [:index, :columns, :options]
  before_action :set_user, only: [:index, :options]
  before_action :myself?, only:[:index, :options], if: :entry_from_mine?


  def authorize_provident_fund
    authorize GoodsSigning unless entry_from_mine?
  end
  # GET /goods_signings/1
  def show
    render json: @goods_signing.as_json(include: :goods_category)
  end

  # POST /goods_signings
  def create
    authorize GoodsSigning
    current_time = Time.zone.now
    created_ids = []
    params[:goods_signing][:user_ids].each do |user_id|
      params[:goods_signing][:distributions].each do |distribution|
        goods_signing = GoodsSigning.create(goods_signing_params.as_json.merge(
            distribution_date: current_time,
            goods_status: 'not_sign',
            user_id: user_id,
            goods_category_id: distribution['goods_category_id'],
            distribution_count: distribution['distribution_count'],
            distribution_total_value: GoodsCategory.find(distribution['goods_category_id']).price_mop * distribution['distribution_count'],
            distributor_id: current_user.id ) )
        goods_signing.update_goods_category_three_counts
        created_ids += [goods_signing.id]
      end
    end
    response_json created_ids
  end

  # PATCH/PUT /goods_signings/1
  def update
    authorize GoodsSigning
    if @goods_signing.update(goods_signing_params.as_json)
      render json: @goods_signing
    else
      render json: @goods_signing.errors, status: :unprocessable_entity
    end
  end

  # GET /goods_signings/signing
  def signing
    @goods_signing.goods_status = 'employee_sign'
    @goods_signing.sign_date = Time.zone.now.strftime('%Y/%m/%d')
    if @goods_signing.save
      # 當員工簽收物品后，需要提醒薪酬組HR：「員工 黃維他 已經簽收了 2件 外套」

      payment_group_users = Role.find_by(key: 'payment_group')&.users
      payment_group_user_ids = payment_group_users.empty? ? nil : payment_group_users.pluck(:id).uniq

      Message.add_notification(@goods_signing,
                               'employee_signed',
                               payment_group_user_ids,
                               { employee: User.find(@goods_signing.user_id),
                                 signed_count: @goods_signing.distribution_count,
                                 goods_category: GoodsCategory.find(@goods_signing.goods_category_id) } ) if payment_group_user_ids
    end
  end

  private
    def set_user
      @user = User.find_by_empoid(params[:employee_id])
    end


    # Use callbacks to share common setup or constraints between actions.
    def set_goods_signing
      @goods_signing = GoodsSigning.detail_by_id params[:id]
    end

    # Only allow a trusted parameter "white list" through.
    def goods_signing_params
      params.require(:goods_signing).permit(*GoodsSigning.create_params)
    end

end
