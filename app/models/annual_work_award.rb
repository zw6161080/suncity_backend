# == Schema Information
#
# Table name: annual_work_awards
#
#  id                 :integer          not null, primary key
#  award_chinese_name :string           not null
#  award_english_name :string           not null
#  begin_date         :string           not null
#  end_date           :string           not null
#  num_of_award       :integer          not null
#  has_paid           :integer          default("false"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})\/(((0[13578]|1[02])\/(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)\/(0[1-9]|[12][0-9]|30))|(02\/(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))\/02\/29)/
      record.errors[attribute] << (options[:message] || "is not a date")
    end
  end
end
class EndDateCannotBeGreaterThanTodayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    year, month, day = value.split('/')
    if day == '29' && month == '02'
      end_date = (Time.zone.local(year, month, day) + 1.year + 1.day).midnight
    else
      end_date = (Time.zone.local(year, month, day) + 1.year).midnight
    end
    if Time.zone.now.midnight < end_date
      record.errors[attribute] << (options[:message] || "can't be greater than today")
    end
  end
end

class AnnualWorkAward < ApplicationRecord
  validates :award_chinese_name, :award_english_name, :num_of_award, presence: true
  validates :award_chinese_name, :award_english_name, uniqueness: true
  validates :end_date, presence: true, date: true
  validates :begin_date, presence: true, date: true,
            end_date_cannot_be_greater_than_today: true
  after_create :create_assistant_profile_to_annual_work_award
  enum has_paid: {true: 1, false: 0}

  def create_assistant_profile_to_annual_work_award
    Profile.all.each do |profile|
      if profile.is_permanent_staff? &&
          profile.data['position_information']['field_values']['date_of_employment']
        date_of_employment = profile.data['position_information']['field_values']['date_of_employment']
        up_to_standard = profile.is_up_to_standard?(self.begin_date)
        if up_to_standard ==1
          money_of_award = profile.get_money_of_award(self.begin_date, self.num_of_award)
          profile.assistant_profile_to_annual_work_award.create(
              date_of_employment: date_of_employment, up_to_standard: up_to_standard,
              money_of_award: money_of_award, annual_work_award_id: self.id)
          result = profile.save
          result
        else
          profile.assistant_profile_to_annual_work_award.create(
              date_of_employment: date_of_employment, up_to_standard: up_to_standard,
              annual_work_award_id: self.id)
          profile.save
        end
      end
    end
  end
end
