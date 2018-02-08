class AddSimpleChineseNameToAttachmentTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :attachment_types, :simple_chinese_name, :string
  end
end
