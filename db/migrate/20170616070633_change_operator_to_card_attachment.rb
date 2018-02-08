class ChangeOperatorToCardAttachment < ActiveRecord::Migration[5.0]
  def change
    remove_column :card_attachments, :operator, :string
    add_column :card_attachments, :operator_id, :integer
  end
end
