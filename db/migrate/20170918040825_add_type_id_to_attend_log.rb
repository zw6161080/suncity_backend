class AddTypeIdToAttendLog < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_logs, :type_id, :integer
    remove_column :attend_logs, :log_date, :date
    remove_column :attend_logs, :log_time, :datetime
  end
end
