# == Schema Information
#
# Table name: attend_attachments
#
#  id              :integer          not null, primary key
#  file_name       :string
#  creator_id      :integer
#  comment         :text
#  attachment_id   :integer
#  attachable_id   :integer
#  attachable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_attend_attachments_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_attend_attachments_on_attachment_id                      (attachment_id)
#  index_attend_attachments_on_creator_id                         (creator_id)
#

class AttendAttachment < ApplicationRecord
  belongs_to :attachable, polymorphic: true
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  def self.create_params
    super - %w(creator_id attachable_type attachable_id)
  end
  def self.update_params
    super - %w(creator_id attachable_type attachable_id) + %w(id)
  end
end
