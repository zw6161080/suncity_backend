class CreatePunchCardStates < ActiveRecord::Migration[5.0]
  def change
    create_table :punch_card_states do |t|
      t.integer :user_id
      t.integer :profile_id
      t.boolean :is_need

      t.boolean :is_effective
      t.date :effective_date
      t.date :start_date
      t.date :end_date
      t.integer :creator_id
      t.integer :source_id

      t.timestamps
    end
  end
end
