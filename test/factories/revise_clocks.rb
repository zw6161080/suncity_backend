# == Schema Information
#
# Table name: revise_clocks
#
#  id          :integer          not null, primary key
#  date        :date
#  user_id     :integer
#  creator_id  :integer
#  status      :integer          default("approved"), not null
#  item_count  :integer
#  comment     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_type :string           default("revise_clock"), not null
#

FactoryGirl.define do
  factory :revise_clock do
    
  end
end
