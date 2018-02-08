class AddColumnsToDimissions1 < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :is_compensation_year, :boolean
  end
end
