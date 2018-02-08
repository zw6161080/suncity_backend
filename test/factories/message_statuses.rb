# == Schema Information
#
# Table name: message_statuses
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  message_id :integer
#  namespace  :string
#  has_read   :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :message_status do
    user_id 1
    message_id 1
  end
end
