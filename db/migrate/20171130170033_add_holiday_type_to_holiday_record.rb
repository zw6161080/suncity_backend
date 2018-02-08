class AddHolidayTypeToHolidayRecord < ActiveRecord::Migration[5.0]
  def change
    remove_column :holiday_records, :holiday_type, :integer
    add_column :holiday_records, :holiday_type, :string
  end
end
