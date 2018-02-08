class RemoveSettingFiledsFromShifts < ActiveRecord::Migration[5.0]
  def change
    remove_column :shifts, :shift_interval_hour
    remove_column :shifts, :rest_number
    remove_column :shifts, :rest_interval_day
    remove_column :shifts, :shift_type_number
  end
end
