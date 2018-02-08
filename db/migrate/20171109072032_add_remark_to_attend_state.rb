class AddRemarkToAttendState < ActiveRecord::Migration[5.0]
  def change
    add_column :attend_states, :remark, :string
  end
end
