class GoodsCategoriesController < ApplicationController

  include StatementBaseActions
  include CurrentUserHelper

  before_action :set_goods_category, only: [:show, :update, :destroy]

  # GET /goods_categories/1
  def show
    render json: @goods_category
  end

  # POST /goods_categories
  def create
    # 物品不能重名
    if GoodsCategory.where(chinese_name: goods_category_params.as_json['chinese_name']).empty? &&
        GoodsCategory.where(english_name: goods_category_params.as_json['english_name']).empty? &&
        GoodsCategory.where(simple_chinese_name: goods_category_params.as_json['simple_chinese_name']).empty?
      goods_category = GoodsCategory.create(goods_category_params.as_json.merge(
          distributed_count: 0,
          returned_count: 0,
          unreturned_count: 0,
          user_id: current_user.id ))
      response_json goods_category
    else
      response_json [], status: :unprocessable_entity
    end
  end

  # PATCH/PUT /goods_categories/1
  def update
    if (@goods_category.chinese_name==goods_category_params['chinese_name'])&&
        (@goods_category.english_name==goods_category_params['english_name'])&&
        (@goods_category.simple_chinese_name==goods_category_params['simple_chinese_name'])
      # 修改名字以外的参数，正常修改
      if @goods_category.update(goods_category_params.as_json)
        render json: @goods_category
      else
        render json: @goods_category.errors, status: :unprocessable_entity
      end
    else
      # 需要修改名字，检查是否 与其他物品类别重名
      if GoodsCategory.where(
          'chinese_name = :chinese_name OR
           english_name = :english_name OR
           simple_chinese_name = :simple_chinese_name',
          chinese_name: goods_category_params['chinese_name'],
          english_name: goods_category_params['english_name'],
          simple_chinese_name: goods_category_params['simple_chinese_name']
      ).where.not(id: @goods_category.id).exists?
        response_json [], status: :unprocessable_entity
      elsif @goods_category.update(goods_category_params.as_json)
        render json: @goods_category
      else
        render json: @goods_category.errors, status: :unprocessable_entity
      end
    end
  end

  # DELETE /goods_categories/1
  def destroy
    if @goods_category.distributed_count == 0
      @goods_category.destroy
    end
  end

  # GET /goods_categories/get_list
  def get_list
    response_json GoodsCategory.select(:id, :chinese_name, :english_name, :simple_chinese_name)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_goods_category
      @goods_category = GoodsCategory.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def goods_category_params
      params.require(:goods_category).permit(*GoodsCategory.create_params)
    end
end
