class ChangeColumnGradeToUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :grade, :string
    add_column :users, :grade, :integer
  end
end
