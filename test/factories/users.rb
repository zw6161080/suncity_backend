# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  empoid              :string
#  chinese_name        :string
#  english_name        :string
#  password_digest     :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  position_id         :integer
#  location_id         :integer
#  department_id       :integer
#  id_card_number      :string
#  email               :string
#  superior_email      :string
#  company_name        :string
#  employment_status   :string
#  grade               :string
#  simple_chinese_name :string
#

FactoryGirl.define do
  factory :user do
    empoid {Faker::Number.hexadecimal(8)}
    password '123456'
    id_card_number {
      Faker::Name.id_card_number
    }

    chinese_name {
      Faker::Name.name
    }

    english_name {
      Faker::Name.name
    }

    email {
      Faker::Internet.email
    }

    superior_email {
      Faker::Internet.email
    }

    grade "1"
    location
  end
end
