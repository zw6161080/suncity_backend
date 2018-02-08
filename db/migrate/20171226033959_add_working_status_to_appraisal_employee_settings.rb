class AddWorkingStatusToAppraisalEmployeeSettings < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisal_employee_settings, :working_status, :string
  end
end
