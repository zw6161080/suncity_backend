# == Schema Information
#
# Table name: applicant_attachments
#
#  id                           :integer          not null, primary key
#  applicant_profile_id         :integer
#  applicant_attachment_type_id :integer
#  attachment_id                :integer
#  file_name                    :string
#  description                  :text
#  creator_id                   :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_applicant_attachments_on_applicant_attachment_type_id  (applicant_attachment_type_id)
#  index_applicant_attachments_on_applicant_profile_id          (applicant_profile_id)
#  index_applicant_attachments_on_attachment_id                 (attachment_id)
#  index_applicant_attachments_on_creator_id                    (creator_id)
#

class ApplicantAttachment < ApplicationRecord
	belongs_to :applicant_profile
	belongs_to :applicant_attachment_type, class_name: 'ProfileAttachmentType', foreign_key: :applicant_attachment_type_id
  belongs_to :attachment
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  
  def destroy
    self.attachment.destroy
    super
  end

  def add_row(params, current_user=nil)
    self.assign_attributes(params)
    self.creator = current_user
    self.save
  end
  
end
