class AddIsCurrentToPunchCardState < ActiveRecord::Migration[5.0]
  def change
    add_column :punch_card_states, :is_current, :boolean
  end
end
