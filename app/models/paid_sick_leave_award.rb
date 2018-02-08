# == Schema Information
#
# Table name: paid_sick_leave_awards
#
#  id                 :integer          not null, primary key
#  award_chinese_name :string           not null
#  award_english_name :string           not null
#  begin_date         :string           not null
#  end_date           :string           not null
#  due_date           :string           not null
#  has_offered        :integer          default("false"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'date_validator'

class EndDateCannotBeGreaterThanOrEqualToDueDateValidator < ActiveModel::Validator
  def validate(record)
    year, month, day = record.begin_date.split('/')
    if day == '29' && month == '02'
      end_date = (Time.zone.local(year, month, day) + 1.year + 1.day).midnight
    else
      end_date = (Time.zone.local(year, month, day) + 1.year).midnight
    end
    year, month, day = record.due_date.split('/')
    due_date = Time.zone.local(year, month, day).midnight
    if end_date > due_date
      record.errors[:due_date] << 'due_date need to be greater than end_date'
    end
  end
end

class PaidSickLeaveAward < ApplicationRecord
  include ActiveModel::Validations
  validates :award_chinese_name, :award_english_name, presence: true
  validates :award_chinese_name, :award_english_name, uniqueness: true
  validates :end_date, :due_date, presence: true, date: true
  validates :begin_date, presence: true, date: true,
            end_date_cannot_be_greater_than_today: true
  validates_with EndDateCannotBeGreaterThanOrEqualToDueDateValidator
  enum has_offered: {true: 1, false: 0}
  after_create :create_assistant_profile

  def create_assistant_profile
    Profile.all.each do |profile|
      if profile.is_permanent_staff? && profile.data['position_information'][
          'field_values']['date_of_employment']
        date_of_employment = profile.data['position_information']['field_values']['date_of_employment']
        days_in_office = profile.get_days_in_office(self.begin_date)
        has_used_days = profile.get_has_used_days(self.begin_date)
        days_of_award = self.get_days_of_award(days_in_office, has_used_days)
        profile.assistant_profile.create(date_of_employment: date_of_employment,
                                         days_in_office: days_in_office,
                                         has_used_days: has_used_days,
                                         days_of_award: days_of_award,
                                         paid_sick_leave_award_id: self.id)
        profile.save
      end
    end
  end

  def get_days_of_award (days_in_office, has_used_days)
    (((days_in_office.to_f/365*6)-has_used_days)/3)
  end
end
