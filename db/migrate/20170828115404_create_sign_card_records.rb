class CreateSignCardRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :sign_card_records do |t|
      t.string :region
      t.integer :user_id

      t.boolean :is_compensate
      t.boolean :is_get_to_work

      t.date :sign_card_date
      t.datetime :sign_card_time

      t.integer :sign_card_setting_id
      t.integer :sign_card_reason_id

      t.text :comment

      t.boolean :is_deleted

      t.integer :creator_id

      t.timestamps
    end
  end
end
