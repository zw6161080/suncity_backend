class AddColumnsToLoactions < ActiveRecord::Migration[5.0]
  def change
    add_column :locations, :location_type, :string, default: :vip_hall
  end
end
