class AddStateToAttendState < ActiveRecord::Migration[5.0]
  def change
    remove_column :attend_states, :state, :integer
    add_column :attend_states, :state, :string
  end
end
