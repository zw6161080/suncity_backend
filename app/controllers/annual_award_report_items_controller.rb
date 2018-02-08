class AnnualAwardReportItemsController < ApplicationController
  include StatementBaseActions
  before_action :set_annual_award_report_item, only: [:update]
  before_action :authorize_provident_fund, only: [:index, :columns, :options]

  def authorize_provident_fund
    authorize AnnualAwardReportItem
  end

  def send_export(query)
    annual_award_report_item_export_num = Rails.cache.fetch('annual_award_report_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+annual_award_report_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('annual_award_report_item_export_number_tag', annual_award_report_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end



  # PATCH/PUT /annual_award_report_items/1
  def update
    if @annual_award_report_item.update(annual_award_report_item_params.permit(:double_pay_alter_hkd))
      render json: @annual_award_report_item
    else
      render json: @annual_award_report_item.errors, status: :unprocessable_entity
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_annual_award_report_item
      @annual_award_report_item = AnnualAwardReportItem.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def annual_award_report_item_params
      params.fetch(:annual_award_report_item, {})
    end
end
