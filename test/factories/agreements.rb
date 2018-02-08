# == Schema Information
#
# Table name: agreements
#
#  id            :integer          not null, primary key
#  title         :string
#  attachment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  region        :string
#

FactoryGirl.define do
  factory :agreement do
    
  end
end
