class AddIsNextToShift < ActiveRecord::Migration[5.0]
  def change
    add_column :shifts, :is_next, :boolean
  end
end
