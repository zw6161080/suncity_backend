# == Schema Information
#
# Table name: applicant_positions
#
#  id                   :integer          not null, primary key
#  department_id        :integer
#  position_id          :integer
#  applicant_profile_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  order                :string
#  status               :integer          default("not_started")
#  comment              :text
#

FactoryGirl.define do
  factory :applicant_position do
    
  end
end
