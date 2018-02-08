class ChangeColumnsToAppraisalAttachments < ActiveRecord::Migration[5.0]
  def change
    remove_reference :appraisal_attachments, :appraisal_basic_setting, foreign_key: true, index: true
    add_reference :appraisal_attachments, :appraisal_attachable, polymorphic: true, index: { :name => 'index_appraisal_attachments_on_appraisal_attachable_id' }
  end
end
