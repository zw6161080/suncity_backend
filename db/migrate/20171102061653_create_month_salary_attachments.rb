class CreateMonthSalaryAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :month_salary_attachments do |t|
      t.string :status
      t.string :file_name
      t.integer :attachment_id
      t.integer :creator_id
      t.string :report_type
      t.decimal :download_process, precision: 15, scale: 2
      t.timestamps
    end
  end
end
