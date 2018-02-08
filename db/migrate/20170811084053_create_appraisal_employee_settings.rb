class CreateAppraisalEmployeeSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_employee_settings do |t|
      t.references :user, index: true, foreign_key: true
      t.references :appraisal_group, index: true, foreign_key: true
      t.references :appraisal_department_setting, foregin_key: true, index: { :name => 'employee_on_department_setting' }
      t.integer :level_in_department
      t.boolean :has_finished
      t.timestamps
    end
  end
end
