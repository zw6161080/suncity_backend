class AddCreaterIdToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :creater_id, :integer
  end
end
