class AddColumnsToCareerRecords2 < ActiveRecord::Migration[5.0]
  def change
    add_column :career_records, :group_id, :integer
  end
end
