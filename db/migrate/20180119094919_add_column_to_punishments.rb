class AddColumnToPunishments < ActiveRecord::Migration[5.0]
  def change
    add_column :punishments, :is_poor_attendance, :boolean
  end
end
