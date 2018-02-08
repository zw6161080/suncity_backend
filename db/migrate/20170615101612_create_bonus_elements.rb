class CreateBonusElements < ActiveRecord::Migration[5.0]
  def change
    create_table :bonus_elements do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :key

      t.timestamps
    end
  end
end
