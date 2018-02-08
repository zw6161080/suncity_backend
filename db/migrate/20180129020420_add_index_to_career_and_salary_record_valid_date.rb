class AddIndexToCareerAndSalaryRecordValidDate < ActiveRecord::Migration[5.0]
  def change
    add_index :career_records, :career_begin
    add_index :career_records, :career_end
    add_index :career_records, :valid_date
    add_index :career_records, :invalid_date

    add_index :salary_records, :salary_begin
    add_index :salary_records, :salary_end
    add_index :salary_records, :valid_date
    add_index :salary_records, :invalid_date
  end
end
