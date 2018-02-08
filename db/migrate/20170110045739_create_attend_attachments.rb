class CreateAttendAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_attachments do |t|
      t.string :file_name
      t.integer :creator_id
      t.text :comment
      t.belongs_to :attachment

      t.integer :attachable_id
      t.string  :attachable_type

      t.timestamps
    end

    add_index :attend_attachments, [:attachable_type, :attachable_id]
  end
end
