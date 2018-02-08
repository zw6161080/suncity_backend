class CreateWorkExperences < ActiveRecord::Migration[5.0]
  def change
    create_table :work_experences do |t|
      t.string :company_organazition
      t.string :work_experience_position
      t.date :work_experience_from
      t.date :work_experience_to
      t.string :job_description
      t.integer :work_experience_salary
      t.string :work_experience_reason_for_leaving
      t.integer :work_experience_company_phone_number
      t.string :former_head
      t.string :work_experience_email
      t.integer :user_id

      t.timestamps
    end
  end
end
