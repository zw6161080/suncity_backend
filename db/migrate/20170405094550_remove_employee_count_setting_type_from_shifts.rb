class RemoveEmployeeCountSettingTypeFromShifts < ActiveRecord::Migration[5.0]
  def change
    remove_column :shifts, :employee_count_setting_type, :integer
  end
end
