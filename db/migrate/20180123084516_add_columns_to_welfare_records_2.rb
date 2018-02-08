class AddColumnsToWelfareRecords2 < ActiveRecord::Migration[5.0]
  def change
    add_column :welfare_records, :position_type, :string
    add_column :welfare_records, :work_days_every_week, :integer
  end
end
