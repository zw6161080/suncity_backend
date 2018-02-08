# == Schema Information
#
# Table name: appraisal_attachments
#
#  id                        :integer          not null, primary key
#  attachment_id             :integer
#  creator_id                :integer
#  file_type                 :string
#  file_name                 :string
#  comment                   :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  appraisal_attachable_type :string
#  appraisal_attachable_id   :integer
#
# Indexes
#
#  index_appraisal_attachments_on_appraisal_attachable_id  (appraisal_attachable_type,appraisal_attachable_id)
#  index_appraisal_attachments_on_attachment_id            (attachment_id)
#  index_appraisal_attachments_on_creator_id               (creator_id)
#
# Foreign Keys
#
#  fk_rails_64aad04d29  (attachment_id => attachments.id)
#

class AppraisalAttachment < ApplicationRecord
  belongs_to :appraisal_attachable, polymorphic: true
  belongs_to :attachment
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
end
