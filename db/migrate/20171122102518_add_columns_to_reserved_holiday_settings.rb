class AddColumnsToReservedHolidaySettings < ActiveRecord::Migration[5.0]
  def change
    add_column :reserved_holiday_settings, :update_date, :datetime
  end
end
