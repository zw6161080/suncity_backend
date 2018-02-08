class AddColumnToCareerRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :career_records, :employment_status, :string
  end
end
