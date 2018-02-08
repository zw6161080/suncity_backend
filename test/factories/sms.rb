# == Schema Information
#
# Table name: sms
#
#  id            :integer          not null, primary key
#  to            :string
#  content       :text
#  user_id       :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  status        :integer          default("not_deliveried")
#  title         :string
#  the_object    :string
#  the_object_id :integer
#  mark          :string
#

FactoryGirl.define do
  factory :sms do

  end
end
