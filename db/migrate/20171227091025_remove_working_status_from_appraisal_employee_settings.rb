class RemoveWorkingStatusFromAppraisalEmployeeSettings < ActiveRecord::Migration[5.0]
  def change
    remove_column :appraisal_employee_settings, :working_status, :string
  end
end
