class AddTypeToAttendState < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_states, :record_type, :integer
    add_column :attend_states, :record_id, :integer
  end
end
