class AddColumnToResignationRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :resignation_records, :notice_date, :datetime
  end
end
