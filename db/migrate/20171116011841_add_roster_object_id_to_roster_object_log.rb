class AddRosterObjectIdToRosterObjectLog < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_object_logs, :roster_object_id, :integer
    remove_column :roster_object_logs, :class_name, :string
    remove_column :roster_object_logs, :working_time, :string
  end
end
