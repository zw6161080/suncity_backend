# == Schema Information
#
# Table name: applicant_profiles
#
#  id             :integer          not null, primary key
#  applicant_no   :string
#  chinese_name   :string
#  english_name   :string
#  id_card_number :string
#  region         :string
#  data           :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  source         :string
#  profile_id     :integer
#  get_info_from  :jsonb
#

FactoryGirl.define do
  factory :applicant_profile do
    applicant_no {Faker::Number.hexadecimal(8)}
  end
end
