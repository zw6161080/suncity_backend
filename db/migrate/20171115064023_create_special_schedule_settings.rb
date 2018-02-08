class CreateSpecialScheduleSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :special_schedule_settings do |t|
      t.references :user, foreign_key: true, index: true
      t.datetime :date_begin
      t.datetime :date_end
      t.text :comment
      t.timestamps
    end

    add_reference :special_schedule_settings, :target_location, index: true
    add_foreign_key :special_schedule_settings, :locations, column: :target_location_id

    add_reference :special_schedule_settings, :target_department, index: true
    add_foreign_key :special_schedule_settings, :departments, column: :target_department_id
  end
end
