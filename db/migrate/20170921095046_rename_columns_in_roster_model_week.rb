class RenameColumnsInRosterModelWeek < ActiveRecord::Migration[5.0]
  def change
    rename_column :roster_model_weeks, :mon_roster_object_id, :mon_class_setting_id
    rename_column :roster_model_weeks, :tue_roster_object_id, :tue_class_setting_id
    rename_column :roster_model_weeks, :wed_roster_object_id, :wed_class_setting_id
    rename_column :roster_model_weeks, :thu_roster_object_id, :thu_class_setting_id
    rename_column :roster_model_weeks, :fri_roster_object_id, :fri_class_setting_id
    rename_column :roster_model_weeks, :sat_roster_object_id, :sat_class_setting_id
    rename_column :roster_model_weeks, :sun_roster_object_id, :sun_class_setting_id
  end
end
