# == Schema Information
#
# Table name: provident_fund_member_report_items
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_provident_fund_member_report_items_on_user_id  (user_id)
#

class ProvidentFundMemberReportItem < ApplicationRecord
  include StatementAble
  belongs_to :user

  scope :by_career_entry_date, lambda { |value|
    from = value[:begin]
    to = value[:end]
    if from && to
      includes(user: :profile)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from ", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  class << self
    def generate_all
      User.all.find_each do |user|
        generate(user)
      end
    end

    def generate(user)
      calc_params = self.create_params - %w(user_id)
      self
          .where(user: user)
          .first_or_create(user_id: user.id)
          .update(
              calc_params.map { |param|
                [param, self.send("calc_#{param}", user)]
              }.to_h
          )
    end


    def calc_career_entry_date(user)
      user.career_entry_date
    end

    def calc_date_of_birth(user)
      user.date_of_birth
    end

    def calc_employment_of_status(user)
      user.employment_of_status
    end

  end
end
