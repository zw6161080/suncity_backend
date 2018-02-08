class RemoveColumnToWelfareRecord < ActiveRecord::Migration[5.0]
  def change
    remove_column :welfare_records, :provide_airfare, :boolean
    remove_column :welfare_records, :provide_accommodation, :boolean
  end
end
