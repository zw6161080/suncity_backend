class CreateCardProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :card_profiles do |t|
      t.integer :photo_id
      t.string :empo_chinese_name
      t.string :empo_english_name
      t.string :empoid
      t.date :entry_date
      t.string :sex
      t.string :nation
      t.string :status
      t.string :approved_job_name
      t.string :approved_job_id
      t.string :allocation_company
      t.date :allocation_valid_date
      t.string :approval_id
      t.integer :report_salary_count
      t.string :report_salary_unit
      t.string :labor_company
      t.date :date_to_submit_data
      t.string :certificate_type
      t.string :certificate_id
      t.date :date_to_submit_certificate
      t.date :date_to_stamp
      t.date :date_to_submit_fingermold
      t.string :card_id
      t.date :cancel_date
      t.string :original_user
      t.text :comment

      t.timestamps
    end
  end
end
