class AddNewCodeToClassSetting < ActiveRecord::Migration[5.0]
  def change
    add_column :class_settings, :new_code, :string
  end
end
