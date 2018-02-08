class CreateAppraisalAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_attachments do |t|
      t.references :appraisal_basic_setting, foreign_key: true, index: true
      t.references :attachment, foreign_key: true, index: true
      t.integer :creator_id
      t.string  :file_type
      t.string  :file_name
      t.text    :comment
      t.timestamps
    end
  end
end
