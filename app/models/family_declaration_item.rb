# == Schema Information
#
# Table name: family_declaration_items
#
#  id                :integer          not null, primary key
#  relative_relation :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  profile_id        :integer
#  creator_id        :integer
#  family_member_id  :integer
#
# Indexes
#
#  index_family_declaration_items_on_creator_id  (creator_id)
#  index_family_declaration_items_on_profile_id  (profile_id)
#

class FamilyDeclarationItem < ApplicationRecord
  validates :creator_id, :family_member_id, :relative_relation, presence:  true
  belongs_to :profile
  belongs_to :family_member, :class_name => "User", :foreign_key => "family_member_id"
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  def add_row(params, current_user=nil)
    self.assign_attributes(params)
    self.creator = current_user
    self.save
  end
end
