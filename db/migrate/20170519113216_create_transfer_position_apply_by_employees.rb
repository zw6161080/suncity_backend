class CreateTransferPositionApplyByEmployees < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_position_apply_by_employees do |t|
      t.string :region
      t.integer :creator_id
      t.integer :user_id
      t.text :comment

      t.date :apply_date
      t.integer :apply_location_id
      t.integer :apply_department_id
      t.integer :apply_position_id

      t.boolean :is_recommended_by_department
      t.string :reason
      t.boolean :is_continued

      t.date :interview_date_by_department
      t.datetime :interview_time_by_department
      t.string :interview_location_by_department

      t.date :interview_date_by_header
      t.datetime :interview_time_by_header
      t.string :interview_location_by_header

      t.boolean :is_transfer
      t.date :transfer_date
      t.integer :transfer_location_id
      t.integer :transfer_department_id
      t.integer :transfer_position_id

      t.timestamps
    end
  end
end
