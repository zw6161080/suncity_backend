class ChangeColumnDefaultValueToMyAttachments < ActiveRecord::Migration[5.0]
  def change
    change_column_default :my_attachments, :download_process, from: nil, to: BigDecimal(0)
  end
end
