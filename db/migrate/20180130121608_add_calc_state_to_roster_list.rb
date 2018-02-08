class AddCalcStateToRosterList < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_lists, :calc_state, :integer
  end
end
