class CreateAttendReturnAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_return_attachments do |t|
      t.string :file_name
      t.integer :creator_id
      t.text :comment
      t.belongs_to :attachment

      t.integer :return_id
      t.string  :return_type

      t.timestamps
    end
    add_index :attend_return_attachments, [:return_type, :return_id]
  end
end
