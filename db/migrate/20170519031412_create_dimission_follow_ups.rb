class CreateDimissionFollowUps < ActiveRecord::Migration[5.0]
  def change
    create_table :dimission_follow_ups do |t|
      t.references :dimission, foreign_key: true, index: true
      t.string :event_key
      t.integer :return_number
      t.decimal :compensation
      t.boolean :is_confirmed
      t.integer :handler_id
      t.boolean :is_checked

      t.timestamps
    end
  end
end
