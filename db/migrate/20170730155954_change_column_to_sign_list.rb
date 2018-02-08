class ChangeColumnToSignList < ActiveRecord::Migration[5.0]
  def change
    add_column :sign_lists, :train_id, :integer
    remove_column :sign_lists, :title_id, :integer
  end
end
