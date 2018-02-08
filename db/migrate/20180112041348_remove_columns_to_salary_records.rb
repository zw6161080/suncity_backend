class RemoveColumnsToSalaryRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_records, :status, :string
  end
end
