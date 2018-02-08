class CreateTransferPositionApplyByDepartments < ActiveRecord::Migration[5.0]
  def change
    create_table :transfer_position_apply_by_departments do |t|
      t.string :region
      t.integer :creator_id
      t.integer :user_id
      t.text :comment

      t.date :apply_date
      t.date :apply_serve_date
      t.integer :apply_location_id
      t.integer :apply_department_id
      t.integer :apply_position_id

      t.text :transfer_position_reason_by_department
      t.boolean :is_agreed_by_employee
      t.text :employee_opinion

      t.boolean :is_hired
      t.boolean :need_pass_trial
      t.integer :hire_position_id
      t.date :effective_date
      t.text :department_comment

      t.boolean :is_transfer
      t.date :transfer_date
      t.integer :transfer_location_id
      t.integer :transfer_department_id
      t.integer :transfer_position_id

      t.timestamps
    end
  end
end
