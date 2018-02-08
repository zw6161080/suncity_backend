class CreateSignCardReasons < ActiveRecord::Migration[5.0]
  def change
    create_table :sign_card_reasons do |t|

      t.string :region

      t.integer :sign_card_setting_id
      t.string :reason
      t.string :reason_code
      t.boolean :be_used
      t.integer :be_used_count, default: 0
      t.text :comment

      t.timestamps
    end
  end
end
