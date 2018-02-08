class EmployeeRedemptionReportItemsController < ApplicationController
  include StatementBaseActions
  before_action :authorize_provident_fund, only: [:index, :columns, :options]

  def authorize_provident_fund
    authorize EmployeeRedemptionReportItem
  end

  def send_export(query)
    employee_redemption_report_item_export_num = Rails.cache.fetch('employee_redemption_report_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+employee_redemption_report_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('employee_redemption_report_item_export_number_tag', employee_redemption_report_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end
end
