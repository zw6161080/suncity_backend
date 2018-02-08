class ChangeRealWorkingHoursToCompensateReport < ActiveRecord::Migration[5.0]
  def change
    remove_column :compensate_reports, :real_working_hours, :integer
    add_column :compensate_reports, :real_working_hours, :float
  end
end
