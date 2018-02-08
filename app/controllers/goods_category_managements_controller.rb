class GoodsCategoryManagementsController < ApplicationController

  include SortParamsHelper
  include CurrentUserHelper
  include GenerateXlsxHelper

  before_action :set_goods_category_management, only: [:show, :update, :destroy]

  # GET /goods_category_managements
  def index
    sort_column = sort_column_sym(params[:sort_column], 'create_date')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
                .order(sort_column => sort_direction)
                .page
                .page(params.fetch(:page, 1))
                .per(20)
    query.each do |record|
      record.can_be_delete = true
      record.can_be_delete = false if record.distributed_number > 0
    end
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    response_json query.as_json(include: :creator), meta: meta
  end

  # GET /goods_category_managements/1
  def show
    response_json @goods_category_management
  end

  # POST /goods_category_managements
  def create
    current_user
    goods_category_management = GoodsCategoryManagement.create(goods_category_management_params.as_json.merge(
        distributed_number: 0,
        collected_number: 0,
        unreturned_number: 0,
        creator_id: current_user.id,
        create_date: DateTime.now.strftime('%Y/%m/%d'),
        can_be_delete: true ))
    response_json goods_category_management
  end

  # PATCH/PUT /goods_category_managements/1
  def update
    if @goods_category_management.update(goods_category_management_params.as_json)
      response_json @goods_category_management
    else
      response_json @goods_category_management.errors, status: :unprocessable_entity
    end
  end

  # DELETE /goods_category_managements/1
  def destroy
    if @goods_category_management.can_be_delete == true
        @goods_category_management.destroy
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goods_category_management
      @goods_category_management = GoodsCategoryManagement.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def goods_category_management_params
      params.require(:goods_category_management).permit(
          *GoodsCategoryManagement.create_params
          # :chinese_name,
          # :english_name,
          # :simple_chinese_name,
          # :unit,
          # :unit_price
      )
    end

    def search_query
      query = GoodsCategoryManagement.includes(:creator)

      {
          unit:               :by_unit,
          unit_price:         :by_unit_price,
          distributed_number: :by_distributed_number,
          collected_number:   :by_collected_number,
          unreturned_number:  :by_unreturned_number,
          creator_id:         :by_creator_id,
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end

      if params[:goods_name]
        if params[:goods_name] =~ /^[A-Za-z]/
          query = query.where(english_name: params[:goods_name])
        else
          query = query.where(chinese_name: params[:goods_name])
        end
      end

      if params[:create_date]
        if params[:create_date][:begin].present? && params[:create_date][:end].present?
          query = query.where(create_date: Time.zone.parse(params[:create_date][:begin])..Time.zone.parse(params[:create_date][:end]))
        elsif params[:create_date][:begin].present? && params[:create_date][:end].blank?
          query = query.where("create_date >= ?", Time.zone.parse(params[:create_date][:begin]))
        elsif params[:create_date][:begin].blank? && params[:create_date][:end].present?
          query = query.where("create_date <= ?", Time.zone.parse(params[:create_date][:end]))
        end
      end
      query
    end

end
