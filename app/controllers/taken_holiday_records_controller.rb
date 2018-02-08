class TakenHolidayRecordsController < ApplicationController
  include StatementBaseActions

  private
  def send_export(query)
    taken_holiday_record_export_num = Rails.cache.fetch('taken_holiday_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ taken_holiday_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('taken_holiday_record_export_number_tag', taken_holiday_record_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end
end
