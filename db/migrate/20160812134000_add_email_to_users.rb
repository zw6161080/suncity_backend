class AddEmailToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email, :string
    add_index :users, :email

    #上级Email
    add_column :users, :superior_email, :string
    add_index :users, :superior_email
  end
end
