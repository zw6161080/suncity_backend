class RemoveUserIdFromWork < ActiveRecord::Migration[5.0]
  def change
    remove_column :work_experences, :user_id, :integer
    remove_column :education_informations, :user_id, :integer
    remove_column :family_declaration_items, :user_id, :integer
  end
end
