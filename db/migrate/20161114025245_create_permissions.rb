class CreatePermissions < ActiveRecord::Migration[5.0]
  def change
    create_table :permissions do |t|
      t.string :resource
      t.string :action
      t.string :chinese_name
      t.string :english_name
      t.belongs_to :role

      t.timestamps
    end
  end
end
