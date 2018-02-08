class CreateJobTransfers < ActiveRecord::Migration[5.0]
  def change
    create_table :job_transfers do |t|
      t.string :region
      t.date :apply_date
      t.integer :user_id

      t.integer :transfer_type
      t.integer :transfer_type_id

      t.date :position_start_date
      t.date :position_end_date

      t.boolean :apply_result
      t.date :trial_expiration_date
      t.integer :salary_template_id

      t.integer :new_company_id
      t.integer :new_location_id
      t.integer :new_department_id
      t.integer :new_position_id
      t.integer :new_grade
      t.integer :new_working_category_id

      t.string :instructions

      t.integer :original_company_id
      t.integer :original_location_id
      t.integer :original_department_id
      t.integer :original_position_id
      t.integer :original_grade
      t.integer :original_working_category_id

      t.integer :inputter_id
      t.date :input_date

      t.string :comment

      t.timestamps
    end
  end
end
