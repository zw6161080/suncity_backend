class AddClassSettingIdToRosterObjectLog < ActiveRecord::Migration[5.0]
  def change
    remove_column :roster_object_logs, :modified_reason, :integer
    add_column :roster_object_logs, :class_setting_id, :integer
    add_column :roster_object_logs, :is_general_holiday, :boolean
    add_column :roster_object_logs, :working_time, :string
    add_column :roster_object_logs, :modified_reason, :string
  end
end
