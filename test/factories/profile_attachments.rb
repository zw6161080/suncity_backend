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

FactoryGirl.define do
  factory :profile_attachment do
    description { Faker::Lorem.sentence }
  end
end
