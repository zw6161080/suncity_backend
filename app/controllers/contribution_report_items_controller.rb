class ContributionReportItemsController < ApplicationController
  include StatementBaseActions
  before_action :authorize_provident_fund, only: [:index, :columns, :options]

  def authorize_provident_fund
    authorize ContributionReportItem
  end

  def year_month_options
    response_json ContributionReportItem.year_month_options&.map{|item| item.beginning_of_month}&.uniq
  end

  def filter(query)
    policy_scope(query)
  end


  def send_export(query)
    contribution_report_item_export_num = Rails.cache.fetch('contribution_report_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ contribution_report_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('contribution_report_item_export_number_tag', contribution_report_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end


end
