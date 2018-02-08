# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  resource   :string
#  action     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  region     :string
#

FactoryGirl.define do
  factory :permission do
    
  end
end
