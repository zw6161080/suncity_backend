# == Schema Information
#
# Table name: online_materials
#
#  id              :integer          not null, primary key
#  name            :string
#  file_name       :string
#  creator_id      :integer
#  instruction     :string
#  attachable_type :string
#  attachable_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  attachment_id   :integer
#
# Indexes
#
#  index_online_materials_on_attachable_type_and_attachable_id  (attachable_type,attachable_id)
#  index_online_materials_on_attachment_id                      (attachment_id)
#  index_online_materials_on_creator_id                         (creator_id)
#

class OnlineMaterial < ApplicationRecord
  belongs_to :attachment
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  def self.create_params
    super - %w(creator_id attachable_type attachable_id)
  end
  def self.update_params
    create_params + %w(id)
  end
end
