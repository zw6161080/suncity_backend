# == Schema Information
#
# Table name: roster_item_logs
#
#  id             :integer          not null, primary key
#  roster_item_id :integer
#  user_id        :integer
#  log_time       :datetime
#  log_type       :string
#  log_type_id    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :roster_item_log do
    
  end
end
