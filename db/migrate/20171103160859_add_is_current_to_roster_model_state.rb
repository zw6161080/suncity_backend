class AddIsCurrentToRosterModelState < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_model_states, :is_current, :boolean
  end
end
