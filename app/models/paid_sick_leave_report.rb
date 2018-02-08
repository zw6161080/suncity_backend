# == Schema Information
#
# Table name: paid_sick_leave_reports
#
#  id           :integer          not null, primary key
#  year         :integer
#  valid_period :date
#  is_release   :boolean
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class PaidSickLeaveReport < ApplicationRecord
  has_many :paid_sick_leave_report_items, dependent: :destroy

  scope :by_year, lambda { |year|
    where(year: year) if year
  }
end
