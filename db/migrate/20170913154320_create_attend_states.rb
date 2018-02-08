class CreateAttendStates < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_states do |t|
      t.integer :attend_id
      t.integer :auto_state
      t.integer :sign_card_state
      t.integer :state
      t.timestamps
    end
  end
end
