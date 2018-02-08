# == Schema Information
#
# Table name: holiday_surplus_reports
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  last_year_surplus :integer
#  total             :integer
#  used              :integer
#  surplus           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_holiday_surplus_reports_on_user_id  (user_id)
#

class HolidaySurplusReport < ApplicationRecord
  belongs_to :user
end
