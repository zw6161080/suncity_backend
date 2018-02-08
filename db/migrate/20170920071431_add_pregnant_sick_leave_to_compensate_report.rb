class AddPregnantSickLeaveToCompensateReport < ActiveRecord::Migration[5.0]
  def change
    add_column :compensate_reports, :pregnant_sick_leave_counts, :integer
  end
end
