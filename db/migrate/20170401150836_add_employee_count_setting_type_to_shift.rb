class AddEmployeeCountSettingTypeToShift < ActiveRecord::Migration[5.0]
  def change
    add_column :shifts, :employee_count_setting_type, :integer
  end
end
