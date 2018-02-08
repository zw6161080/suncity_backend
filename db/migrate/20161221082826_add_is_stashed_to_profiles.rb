class AddIsStashedToProfiles < ActiveRecord::Migration[5.0]
  def change
    add_column :profiles, :is_stashed, :boolean, default: false
  end
end
