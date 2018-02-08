class SocialSecurityFundItemsController < ApplicationController
  include StatementBaseActions
  before_action :authorize_provident_fund, only: [:index, :columns, :options]

  def authorize_provident_fund
    authorize SocialSecurityFundItem
  end


  def filter(query)
    policy_scope(query)
  end

  def year_month_options
    render json: SocialSecurityFundItem.year_month_options
  end

  def send_export(query)
    social_security_fund_item_export_num = Rails.cache.fetch('social_security_fund_item_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+social_security_fund_item_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('social_security_fund_item_export_number_tag', social_security_fund_item_export_num + 1)
    "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end
end
