class CreateEmpoCards < ActiveRecord::Migration[5.0]
  def change
    create_table :empo_cards do |t|
      t.string :approved_job_name
      t.string :approved_job_number
      t.date :approval_valid_date
      t.integer :report_salary_count
      t.string :report_salary_unit
      t.date :allocation_valid_date
      t.integer :approved_number
      t.integer :used_number
      t.string :operator_name
      t.references :approved_job, foreign_key: true

      t.timestamps
    end
  end
end
