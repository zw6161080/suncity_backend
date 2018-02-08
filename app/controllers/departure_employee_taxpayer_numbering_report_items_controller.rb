class DepartureEmployeeTaxpayerNumberingReportItemsController < ApplicationController
  include StatementBaseActions
  before_action :authorize_provident_fund, only: [:index, :columns, :options, :update_beneficiary_name]

  def authorize_provident_fund
    authorize DepartureEmployeeTaxpayerNumberingReportItem
  end

  def year_month_options
    render json: DepartureEmployeeTaxpayerNumberingReportItem.year_month_options, adapter: :attributes
  end

  def update_beneficiary_name
    if params[:beneficiary_name] && DepartureEmployeeTaxpayerNumberingReportItem.find(params[:id]).update(beneficiary_name: params[:beneficiary_name ])
      response_json true
    else
      response_json params[:beneficiary_name], error: true
    end
  end


  def send_export(query)
    departure_employee_taxpayer_numbering_report_item_export_num = Rails.cache.fetch('departure_employee_taxpayer_numbering_report_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+departure_employee_taxpayer_numbering_report_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('departure_employee_taxpayer_numbering_report_item_export_number_tag', departure_employee_taxpayer_numbering_report_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

end
