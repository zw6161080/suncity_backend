class CreateShiftStates < ActiveRecord::Migration[5.0]
  def change
    create_table :shift_states do |t|
      t.belongs_to :user
      t.jsonb :first_state
      t.jsonb :second_state

      t.timestamps
    end
  end
end
