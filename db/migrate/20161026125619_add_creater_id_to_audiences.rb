class AddCreaterIdToAudiences < ActiveRecord::Migration[5.0]
  def change
    add_column :audiences, :creater_id, :integer
  end
end
