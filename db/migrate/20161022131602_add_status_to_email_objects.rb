class AddStatusToEmailObjects < ActiveRecord::Migration[5.0]
  def change
    add_column :email_objects, :status, :integer, default: 0
  end
end
