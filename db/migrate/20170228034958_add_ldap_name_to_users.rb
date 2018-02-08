class AddLdapNameToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ldap_name, :string
  end
end
