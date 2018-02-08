class AddTypeToDimissions < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :type, :string
  end
end
