class RemoveLdapNameToUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :ldap_name, :string
  end
end
