class AddProfileIdToWork < ActiveRecord::Migration[5.0]
  def change
    add_column :work_experences, :profile_id, :integer
    add_column :work_experences, :creator_id, :integer
    add_column :education_informations, :profile_id, :integer
    add_column :education_informations, :creator_id, :integer
    add_column :family_declaration_items, :profile_id, :integer
    add_column :family_declaration_items, :creator_id, :integer
  end
end
