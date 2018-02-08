class AddTrackerToPunishment < ActiveRecord::Migration[5.0]
  def change
    add_column :punishments, :track_date, :datetime
    add_reference :punishments, :tracker, foreign_key: {to_table: :users}
    remove_column :punishments, :punishment_recorder, :string
  end
end
