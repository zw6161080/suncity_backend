class ChangeColumnsToWelfareRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :welfare_records, :status, :string
  end
end
