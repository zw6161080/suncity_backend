# == Schema Information
#
# Table name: over_time_items
#
#  id             :integer          not null, primary key
#  over_time_id   :integer
#  over_time_type :integer
#  make_up_type   :integer
#  from           :string
#  to             :string
#  duration       :float
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  comment        :text
#  to_date        :datetime
#  date           :date
#  shift_info     :string
#  work_time      :string
#  come           :string
#  leave          :string
#

FactoryGirl.define do
  factory :over_time_item do
    
  end
end
