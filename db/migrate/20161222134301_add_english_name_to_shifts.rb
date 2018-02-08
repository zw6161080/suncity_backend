class AddEnglishNameToShifts < ActiveRecord::Migration[5.0]
  def change
    rename_column :shifts, :name, :chinese_name
    add_column :shifts, :english_name, :string
  end
end
