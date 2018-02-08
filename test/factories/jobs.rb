# == Schema Information
#
# Table name: jobs
#
#  id                :integer          not null, primary key
#  department_id     :integer
#  position_id       :integer
#  superior_email    :string
#  grade             :string
#  number            :integer
#  chinese_range     :text
#  english_range     :text
#  chinese_skill     :text
#  english_skill     :text
#  chinese_education :text
#  english_education :text
#  status            :integer          default("enabled")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  region            :string
#  need_number       :integer
#

FactoryGirl.define do
  factory :job do
    region 'macau'
    superior_email { Faker::Internet.email }
    grade '6'
    number '6'
    chinese_range { Faker::Lorem.sentence }
    english_range { Faker::Lorem.sentence }
    chinese_skill { Faker::Lorem.sentence }
    english_skill { Faker::Lorem.sentence }
    chinese_education { Faker::Lorem.sentence }
    english_education { Faker::Lorem.sentence }

    factory :job_with_full_relations do
      after(:create) do |job|
        department = create(:department)
        position = create(:position)

        job.department_id = department.id
        job.position_id = position.id
        job.save
      end

    end
  end
end
