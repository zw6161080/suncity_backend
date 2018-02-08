class CreateApplicantAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :applicant_attachments do |t|
      t.belongs_to :applicant_profile
      # Index name too long, so I shorten the name;
      t.belongs_to :applicant_attachment_type
      t.belongs_to :attachment
      t.string :file_name
      t.text :description
      t.integer :creater_id

      t.timestamps
    end
  end
end
