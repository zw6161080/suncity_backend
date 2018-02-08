class AddSourceIdToOvertimeRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :overtime_records, :source_id, :integer
  end
end
