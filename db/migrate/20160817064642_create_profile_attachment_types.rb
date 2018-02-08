class CreateProfileAttachmentTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :profile_attachment_types do |t|
      t.string :chinese_name
      t.string :english_name
      t.text :description

      t.timestamps
    end
  end
end
