class AddColumnToLoveFunds < ActiveRecord::Migration[5.0]
  def change
    add_column :love_funds, :operator_id, :integer
  end
end
