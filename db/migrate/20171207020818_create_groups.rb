class CreateGroups < ActiveRecord::Migration[5.0]
  def change
    create_table :groups do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :region_key
      t.boolean :can_be_destroy, default: true
      t.timestamps
    end
  end
end
