# == Schema Information
#
# Table name: attachment_items
#
#  id              :integer          not null, primary key
#  file_name       :string
#  creator_id      :integer
#  comment         :text
#  attachment_id   :integer
#  attachable_type :string
#  attachable_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_attachment_items_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_attachment_items_on_attachment_id                      (attachment_id)
#  index_attachment_items_on_creator_id                         (creator_id)
#
# Foreign Keys
#
#  fk_rails_81e42d603c  (attachment_id => attachments.id)
#

class AttachmentItem < ApplicationRecord
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  belongs_to :attachment
  belongs_to :attachable, polymorphic: true
end
