class AddCurrentIsShiftDefaultValueToShiftStates < ActiveRecord::Migration[5.0]
  def change
    change_column_default :shift_states, :current_is_shift, true
  end
end
