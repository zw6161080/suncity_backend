# == Schema Information
#
# Table name: profile_attachments
#
#  id                         :integer          not null, primary key
#  profile_id                 :integer
#  profile_attachment_type_id :integer
#  attachment_id              :integer
#  description                :text
#  creator_id                 :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  file_name                  :string
#
# Indexes
#
#  index_profile_attachments_on_attachment_id               (attachment_id)
#  index_profile_attachments_on_creator_id                  (creator_id)
#  index_profile_attachments_on_profile_attachment_type_id  (profile_attachment_type_id)
#  index_profile_attachments_on_profile_id                  (profile_id)
#

class ProfileAttachment < ApplicationRecord
	belongs_to :profile
	belongs_to :profile_attachment_type, foreign_key: 'profile_attachment_type_id'
  belongs_to :attachment
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  after_create :update_profile_filled_attachment_types
  before_destroy :update_profile_filled_attachment_types

  def destroy
    self.attachment.destroy
    super
  end

  def add_row(params, current_user=nil)
    self.assign_attributes(params)
    self.creator = current_user
    self.save
  end

  def update_profile_filled_attachment_types
    profile.update_filled_attachment_types
  end
  
end
