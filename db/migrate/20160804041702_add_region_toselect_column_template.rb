class AddRegionToselectColumnTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :select_column_templates, :region, :string, index: true
  end
end
