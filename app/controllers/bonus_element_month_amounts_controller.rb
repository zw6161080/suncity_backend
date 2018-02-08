class BonusElementMonthAmountsController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  before_action :set_bonus_element_month_amount, only: [:show, :update, :destroy]

  # GET /bonus_element_month_amounts
  def index
    authorize BonusElementMonthAmount
    @bonus_element_month_amounts = BonusElementMonthAmount.query(bonus_element_month_amount_query_params)

    respond_to do |format|
      format.json {
        render json: @bonus_element_month_amounts
      }
      format.xlsx {
        employee_redemption_report_item_export_num = Rails.cache.fetch('employee_redemption_report_item_export_number', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+employee_redemption_report_item_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('employee_redemption_report_item_export_number', employee_redemption_report_item_export_num + 1)
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateBonusElementMonthAmountsTableJob.perform_later(query_ids:  @bonus_element_month_amounts.ids, query_model: 'bonus_element_month_amounts', float_salary_month_entry_id: params[:float_salary_month_entry_id], my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  # GET /bonus_element_month_amounts/1
  # def show
  #   render json: @bonus_element_month_amount
  # end

  # PATCH/PUT /bonus_element_month_amounts/1
  def update
    authorize BonusElementMonthAmount
    if @bonus_element_month_amount.update(bonus_element_month_amount_params)
      render json: @bonus_element_month_amount
    else
      render json: @bonus_element_month_amount.errors, status: :unprocessable_entity
    end
  end

  # DELETE /bonus_element_month_amounts/1
  # def destroy
  #   @bonus_element_month_amount.destroy
  # end

  def batch_update
    authorize BonusElementMonthAmount
    if BonusElementMonthAmount.batch_update(bonus_element_month_amount_batch_update_params[:updates])
      render json: { success: true }, status: :ok
    else
      render json: { error: 'update failed' }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bonus_element_month_amount
      @bonus_element_month_amount = BonusElementMonthAmount.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def bonus_element_month_amount_params
      params
        .require(:bonus_element_month_amount)
        .permit(:amount)
    end

    def bonus_element_month_amount_query_params
      params.permit(
        :location_id,
        :department_id,
        :float_salary_month_entry_id,
        :bonus_element_id,
        :year_month
      )
    end

    def bonus_element_month_amount_batch_update_params
      params
        .require(:bonus_element_month_amount)
        .permit(updates: [:id, :amount])
    end
end
