class EmployeeFundSwitchingReportItemsController < ApplicationController
  include StatementBaseActions
  before_action :authorize_provident_fund, only: [:index, :columns, :options]

  def authorize_provident_fund
    authorize EmployeeFundSwitchingReportItem
  end


  def send_export(query)
    employee_fund_switching_report_item_export_num = Rails.cache.fetch('employee_fund_switching_report_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+employee_fund_switching_report_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('employee_redemption_report_item_export_number_tag', employee_fund_switching_report_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def add_title
    'add_employee_fund_switching_report_title'
  end
end
