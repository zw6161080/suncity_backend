class RemoveColumnsToLentRecordsAndMuseumRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :lent_records, :status, :string
    remove_column :museum_records, :status, :string
  end
end
