class AddRecordTypeAndRemoveTypeToHolidaySwitches < ActiveRecord::Migration[5.0]
  def change
    remove_column :holiday_switches, :type, :integer
    add_column :holiday_switches, :record_type, :string, null: false , default: 'holiday_switch'
  end
end
