class AddColumnsToResignationRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :resignation_records, :last_work_date, :datetime
    add_column :resignation_records, :final_work_date, :datetime
    add_column :resignation_records, :is_in_blacklist, :datetime
  end
end
