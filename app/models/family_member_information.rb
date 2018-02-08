# == Schema Information
#
# Table name: family_member_informations
#
#  id                           :integer          not null, primary key
#  family_fathers_name_chinese  :string
#  family_fathers_name_english  :string
#  family_mothers_name_chinese  :string
#  family_mothers_name_english  :string
#  family_partenrs_name_chinese :string
#  family_partenrs_name_english :string
#  family_kids_name_chinese     :string
#  family_kids_name_english     :string
#  family_bothers_name_chinese  :string
#  family_bothers_name_english  :string
#  family_sisters_name_chinese  :string
#  family_sisters_name_english  :string
#  user_id                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_family_member_informations_on_user_id  (user_id)
#

class FamilyMemberInformation < ApplicationRecord
  belongs_to :user
end
