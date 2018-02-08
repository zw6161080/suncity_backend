class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :region, index: true

      t.timestamps
    end
  end
end
