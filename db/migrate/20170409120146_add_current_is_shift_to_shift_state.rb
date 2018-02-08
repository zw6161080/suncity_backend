class AddCurrentIsShiftToShiftState < ActiveRecord::Migration[5.0]
  def change
    add_column :shift_states, :current_is_shift, :boolean
    add_column :shift_states, :current_working_hour, :string
    add_column :shift_states, :future_is_shift, :boolean
    add_column :shift_states, :future_working_hour, :string
    add_column :shift_states, :future_affective_date, :datetime

    remove_column :shift_states, :first_state, :jsonb
    remove_column :shift_states, :second_state, :jsonb
  end
end
