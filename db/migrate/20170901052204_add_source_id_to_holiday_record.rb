class AddSourceIdToHolidayRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :holiday_records, :source_id, :integer
  end
end
