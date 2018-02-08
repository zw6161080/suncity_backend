class AddColumnsToDimissions2 < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :notice_period_compensation, :boolean
    remove_column :dimissions, :group_id, :string
    add_column :dimissions, :group_id, :integer
  end
end
