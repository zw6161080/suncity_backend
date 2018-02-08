class AddHolidayRecordToRosterObject < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_objects, :holiday_record_id, :integer
    add_column :roster_objects, :working_hours_transaction_record_id, :integer
  end
end
