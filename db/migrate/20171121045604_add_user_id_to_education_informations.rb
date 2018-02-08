class AddUserIdToEducationInformations < ActiveRecord::Migration[5.0]
  def change
    add_column :education_informations, :user_id, :integer
  end
end
