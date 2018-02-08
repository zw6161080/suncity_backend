class BonusElementItemValuesController < ApplicationController
  before_action :set_bonus_element_item_value, only: [:show, :update]

  # GET /bonus_element_item_values/1
  # def show
  #   render json: @bonus_element_item_value
  # end

  # PATCH/PUT /bonus_element_item_values/1
  def update
    authorize BonusElementItemValue
    update_params = @bonus_element_item_value.value_type == 'personal' ? personal_params : departmental_params
    amount = BigDecimal(params[:shares]) * BigDecimal(params[:per_share]) rescue 0
    # update_params = update_params.merge(amount: amount) if @bonus_element_item_value.value_type == 'departmental'
    if @bonus_element_item_value.update(update_params)
      if %w(kill_bonus performance_bonus).include? @bonus_element_item_value.bonus_element.key
        bonus_element_item_values = BonusElementItemValue.where(bonus_element_item_id: @bonus_element_item_value.bonus_element_item_id).joins(:bonus_element)
        kill_bonus_item = bonus_element_item_values.where(:bonus_elements => { key: 'kill_bonus' }).first
        performance_bonus_item = bonus_element_item_values.where(:bonus_elements => { key: 'performance_bonus' }).first
        kill_bonus = get_amount_of_item_value(kill_bonus_item)
        performance_bonus = get_amount_of_item_value(performance_bonus_item)
        if performance_bonus < 0
          kill_bonus = kill_bonus + performance_bonus
          kill_bonus = BigDecimal(0) if kill_bonus < 0
          performance_bonus = BigDecimal(0)
        end
        kill_bonus_item.update(amount: kill_bonus)
        performance_bonus_item.update(amount: performance_bonus)
      else
        @bonus_element_item_value.update(amount: amount) if @bonus_element_item_value.value_type == 'departmental'
      end
      render json: @bonus_element_item_value
    else
      render json: @bonus_element_item_value.errors, status: :unprocessable_entity
    end
  end

  private
  def get_amount_of_item_value(item_value)
    return (params[:amount] || BigDecimal(0)) if item_value.personal?
    shares = item_value.shares
    per_share = item_value.per_share
    amount = shares * per_share
    if item_value.bonus_element.key == 'performance_bonus'
      amount = amount * item_value.basic_salary
    end
    amount
  end
    # Use callbacks to share common setup or constraints between actions.
    def set_bonus_element_item_value
      @bonus_element_item_value = BonusElementItemValue.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
  def personal_params
    params.require(:amount)
    params.permit(:amount)
  end

  def departmental_params
    params.require(:shares)
    params.require(:per_share)
    params.permit(:shares, :per_share)
  end

    def bonus_element_item_value_params
      params.require(:bonus_element_item_value).permit(:shares, :per_share, :amount)
    end
end
