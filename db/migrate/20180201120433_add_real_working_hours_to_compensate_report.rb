class AddRealWorkingHoursToCompensateReport < ActiveRecord::Migration[5.0]
  def change
    add_column :compensate_reports, :real_working_hours, :integer
  end
end
