# == Schema Information
#
# Table name: annual_attend_reports
#
#  id              :integer          not null, primary key
#  department_id   :integer
#  user_id         :integer
#  year            :integer
#  is_meet         :boolean
#  settlement_date :date
#  money_hkd       :decimal(15, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_annual_attend_reports_on_user_id  (user_id)
#

class AnnualAttendReport < ApplicationRecord
  belongs_to :user

  scope :by_department_ids, lambda { |department_ids|
    if department_ids
      joins(:user).where(users: { department_id: department_ids })
    end
  }

  scope :by_users, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_year, lambda { |year|
    where(year: year) if year
  }

  scope :by_is_meet, lambda { |is_meet|
    if is_meet != nil
      where(is_meet: is_meet)
    end
  }
end
