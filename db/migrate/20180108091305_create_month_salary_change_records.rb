class CreateMonthSalaryChangeRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :month_salary_change_records do |t|
      t.references :user, foreign_key: true, index: true
      t.timestamps
    end

    add_reference :month_salary_change_records, :original_salary_record, index: true
    add_foreign_key :month_salary_change_records, :salary_records, column: :original_salary_record_id

    add_reference :month_salary_change_records, :updated_salary_record, index: true
    add_foreign_key :month_salary_change_records, :salary_records, column: :updated_salary_record_id

  end
end
