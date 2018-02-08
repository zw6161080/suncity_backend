class AddConditionToRosters < ActiveRecord::Migration[5.0]
  def change
    add_column :rosters, :condition, :jsonb
  end
end
