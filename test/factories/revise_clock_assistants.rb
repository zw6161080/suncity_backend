# == Schema Information
#
# Table name: revise_clock_assistants
#
#  id                   :integer          not null, primary key
#  revise_clock_item_id :integer
#  sign_time            :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

FactoryGirl.define do
  factory :revise_clock_assistant do
    
  end
end
