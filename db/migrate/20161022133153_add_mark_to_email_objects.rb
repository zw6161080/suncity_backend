class AddMarkToEmailObjects < ActiveRecord::Migration[5.0]
  def change
    add_column :email_objects, :mark, :string
  end
end
