# == Schema Information
#
# Table name: public_holidays
#
#  id           :integer          not null, primary key
#  chinese_name :string
#  english_name :string
#  category     :integer
#  start_date   :date
#  end_date     :date
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PublicHoliday < ApplicationRecord
  enum category:{
      public_holiday: 0,
      force_holiday:1
  }
end
