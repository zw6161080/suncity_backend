class RemoveColumnsToCareerRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :career_records, :status, :string
  end
end
