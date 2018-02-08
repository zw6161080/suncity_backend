class AddCodeToClassSetting < ActiveRecord::Migration[5.0]
  def change
    remove_column :class_settings, :code, :integer
    add_column :class_settings, :code, :string
  end
end
