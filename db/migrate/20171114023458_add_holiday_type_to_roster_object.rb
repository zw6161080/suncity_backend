class AddHolidayTypeToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :holiday_type, :string
  end
end
