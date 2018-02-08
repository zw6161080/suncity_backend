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
# Indexes
#
#  index_over_time_items_on_over_time_id  (over_time_id)
#

class OverTimeItem < ApplicationRecord
  belongs_to :over_time
  enum over_time_type: { holiday_work: 1, weekday_work: 2}
  enum make_up_type: { add_money: 1, add_holiday: 2 }
  
end
