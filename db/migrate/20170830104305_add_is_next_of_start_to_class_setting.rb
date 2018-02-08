class AddIsNextOfStartToClassSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :class_settings, :is_next_of_start, :boolean
    add_column :class_settings, :is_next_of_end, :boolean
  end
end
