class CreateRegions < ActiveRecord::Migration[5.0]
  def change
    create_table :regions, id: false do |t|
      t.string :key, primary_key: true
      t.string :chinese_name
      t.string :english_name
      t.timestamps
    end
  end
end
