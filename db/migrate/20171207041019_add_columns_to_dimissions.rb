class AddColumnsToDimissions < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :company_name, :string
    add_column :dimissions, :group_id, :string
    add_column :dimissions, :final_work_date, :datetime
  end
end
