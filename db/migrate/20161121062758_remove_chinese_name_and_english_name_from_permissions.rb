class RemoveChineseNameAndEnglishNameFromPermissions < ActiveRecord::Migration[5.0]
  def change
    remove_column :permissions, :chinese_name
    remove_column :permissions, :english_name
  end
end
