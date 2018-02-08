# == Schema Information
#
# Table name: message_infos
#
#  id          :integer          not null, primary key
#  content     :string
#  target_type :string
#  namespace   :string
#  targets     :integer          is an Array
#  sender_id   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

FactoryGirl.define do
  factory :message_info do
    content "MyString"
    target_type "MyString"
    targets ""
    sender_id "MyString"
  end
end
