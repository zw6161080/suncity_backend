class CreateSignCardSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :sign_card_settings do |t|

      t.string :region
      t.string :code
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.text :comment

      t.timestamps
    end
  end
end
