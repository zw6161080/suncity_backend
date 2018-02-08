class CreateCareerRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :career_records do |t|
      t.integer :user_id
      t.string :status
      t.datetime :career_begin
      t.datetime :career_end
      t.string :deployment_type
      t.datetime :trial_period_expiration_date
      t.string :salary_calculation
      t.string :company_name
      t.integer :location_id
      t.integer :position_id
      t.integer :department_id
      t.integer :grade
      t.string :division_of_job
      t.string :deployment_instructions
      t.integer :inputer_id
      t.string :comment
      t.timestamps
    end
  end
end
