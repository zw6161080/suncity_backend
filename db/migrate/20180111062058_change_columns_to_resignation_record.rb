class ChangeColumnsToResignationRecord < ActiveRecord::Migration[5.0]
  def change
    remove_column :resignation_records, :is_in_blacklist, :datetime
    remove_column :resignation_records, :last_work_date, :datetime
    add_column :resignation_records, :is_in_whitelist, :boolean, default: true
  end
end
