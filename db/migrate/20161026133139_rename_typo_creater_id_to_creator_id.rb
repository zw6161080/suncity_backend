class RenameTypoCreaterIdToCreatorId < ActiveRecord::Migration[5.0]
  def change
    rename_column :audiences, :creater_id, :creator_id
    rename_column :interviewers, :creater_id, :creator_id
    rename_column :profile_attachments, :creater_id, :creator_id
    rename_column :applicant_attachments, :creater_id, :creator_id
    rename_column :agreement_files, :creater_id, :creator_id
  end
end
