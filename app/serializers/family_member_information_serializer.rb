class FamilyMemberInformationSerializer < ActiveModel::Serializer
  attributes :id, :family_fathers_name_chinese, :family_fathers_name_english, :family_mothers_name_chinese, :family_mothers_name_english, :family_partenrs_name_chinese, :family_partenrs_name_english, :family_kids_name_chinese, :family_kids_name_english, :family_bothers_name_chinese, :family_bothers_name_english, :family_sisters_name_chinese, :family_sisters_name_english, :user_id
end
