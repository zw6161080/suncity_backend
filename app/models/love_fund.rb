# coding: utf-8
# == Schema Information
#
# Table name: love_funds
#
#  id                :integer          not null, primary key
#  participate       :string
#  monthly_deduction :decimal(10, 2)
#  user_id           :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  participate_date  :datetime
#  cancel_date       :datetime
#  to_status         :string
#  profile_id        :integer
#  operator_id       :integer
#
# Indexes
#
#  index_love_funds_on_monthly_deduction  (monthly_deduction)
#  index_love_funds_on_participate        (participate)
#  index_love_funds_on_profile_id         (profile_id)
#  index_love_funds_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_9b68a4cb54  (user_id => users.id)
#

class LoveFund < ApplicationRecord
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :profile
  enum participate: { participated: 'love_fund.enum_participate.participated',
                      not_participated: 'love_fund.enum_participate.not_participated' }
  enum to_status: { participated_in_the_future: 'love_fund.enum_participate.participated',
                      not_participated_in_the_future: 'love_fund.enum_participate.not_participated' }

  def self.update_love_fund
    LoveFund.all.each do |record|
      if record.to_status == 'participated_in_the_future'
        if valid_date_is_effective?(record.participate_date)
          if !LoveFundRecord.where(user_id: record.user_id).order(created_at: :desc).first&.participate
            LoveFundRecord.create(user_id: record.id, participate: true, participate_begin: Time.zone.now.beginning_of_day, creator_id: record.operator_id)
          end
        end
      else
        if valid_date_is_effective?(record.participate_date)
          if LoveFundRecord.where(user_id: record.user_id).order(created_at: :desc).first&.participate
            LoveFundRecord.create(user_id: record.id, participate: false, participate_begin: Time.zone.now.beginning_of_day, creator_id: record.operator_id)
          end
        end
      end
    end
  end

  def is_participate?
    !!((self.to_status == 'participated_in_the_future' && (self.participate_date.nil? ||self.participate_date < Time.now)) || (self.to_status == 'not_participated_in_the_future' && self.cancel_date  &&self.cancel_date > Time.zone.now.midnight))
  end



  def self.create_with_params(user, valid_date, to_status, creator_id)
    if to_status == 'participated_in_the_future'
      if valid_date_is_effective?(valid_date)
        ActiveRecord::Base.transaction do
          LoveFund.create!(user_id: user.id, profile_id: user.profile.id, participate: 'not_participated', to_status: 'participated_in_the_future', participate_date: valid_date, operator_id: creator_id)
          LoveFundRecord.create!(user_id: user.id, participate: true, participate_begin: valid_date, creator_id: creator_id)
        end
      else
        LoveFund.create(user_id: user.id,profile_id: user.profile.id, participate: 'not_participated', to_status: 'participated_in_the_future', participate_date: valid_date, operator_id: creator_id)
      end
    elsif to_status == 'not_participated_in_the_future'
      LoveFund.create(user_id: user.id,profile_id: user.profile.id, participate: 'participated', to_status: 'not_participated_in_the_future', operator_id: creator_id)
    end
  end


  def  self.get_update_result(love_fund, valid_date, to_status, creator_id)
    ActiveRecord::Base.transaction do
      result = if love_fund.to_status  == 'participated_in_the_future'
        if valid_date_is_effective?(love_fund.participate_date)
          if love_fund.to_status == to_status
            {}
          else
            LoveFundRecord.create!(user_id: love_fund.user_id, participate: false, participate_begin: valid_date, creator_id: creator_id)
            {to_status: to_status, cancel_date: valid_date, participate: 'participated', operator_id: creator_id}
          end
        else
          if love_fund.to_status == to_status
            {participate_date: valid_date, operator_id: creator_id}
          else
            {to_status: to_status, participate: 'participated', operator_id: creator_id}
          end
        end
      else
        if valid_date_is_effective?(love_fund.cancel_date)
          if love_fund.to_status == to_status
            {}
          else
            LoveFundRecord.create!(user_id: love_fund.user_id, participate: true, participate_begin: valid_date, creator_id: creator_id)
            {to_status: to_status, participate_date: valid_date, participate: 'not_participated', operator_id: creator_id}
          end
        else
          if love_fund.to_status == to_status
            {cancel_date: valid_date, operator_id: creator_id}
          else
            {to_status: to_status, participate: 'not_participated', operator_id: creator_id}
          end
        end
      end
      love_fund.update(result)
    end
  end


  def self.valid_date_is_effective?(valid_date)
    if valid_date.nil?
      true
    else
      valid_date < (Time.zone.now.midnight + 1.day)
    end
  end

  def self.detail_by_id(id)
    LoveFund.includes(:user).find(id)
  end

  def self.detail_by_ids(ids)
    data = LoveFund.where(user_id: ids)
    absence_user_ids = ids.map(&:to_i) - LoveFund.where(user_id: ids).pluck(:user_id)
    {
        data: data,
        absence_user_ids: absence_user_ids,
    }
  end

  def self.field_options
    user_query = self.left_outer_joins(user: [:position, :department])
    positions = user_query.select('positions.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    grades = [
        {key: 1, chinese_name: 1, english_name: 1},
        {key: 2, chinese_name: 2, english_name: 2},
        {key: 3, chinese_name: 3, english_name: 3},
        {key: 4, chinese_name: 4, english_name: 4},
        {key: 5, chinese_name: 5, english_name: 5}
    ]
    return {
        positions: positions,
        departments: departments,
        grades: grades,
        participate: ['participated', 'not_participated'],
    }
  end

  def get_json_data
    fund_data = self.as_json(include: { user: { include: [:department, :position] }})
    fund_data['date_of_employment'] = User.find(self['user_id'])
                                         .profile
                                         .data['position_information']['field_values']['date_of_employment']
    fund_data['is_participate'] = self.is_participate?
    fund_data['monthly_deduction'] = if self.is_participate?
                                      BigDecimal(20)
                                     else
                                      BigDecimal(0)
                                     end
    fund_data['valid_date'] = if self.to_status  == 'participated_in_the_future'
                                if LoveFund.valid_date_is_effective?(self.participate_date)
                                  self.participate_date
                                else
                                  self.cancel_date
                                end
                              else
                                if LoveFund.valid_date_is_effective?(self.cancel_date)
                                  self.cancel_date
                                else
                                  self.participate_date
                                end
                              end
    fund_data
  end

  scope :by_employee_no, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }

  scope :by_employee_grade, lambda { |grade|
    where(users: {grade: grade})
  }

  scope :by_participate, lambda { |participate|
    if participate.include?('participated') && participate.include?('not_participated')
      where('1=1')
    elsif participate.include?('participated')
      where("(to_status = 'love_fund.enum_participate.participated' AND (participate_date IS NULL OR participate_date <= :now_day)) OR (to_status = 'love_fund.enum_participate.not_participated'  AND cancel_date IS NOT NULL AND cancel_date > :now_day)", now_day: Time.zone.now.beginning_of_day)
    elsif participate.include?('not_participated')
      where.not("(to_status = 'love_fund.enum_participate.participated' AND (participate_date IS NULL OR participate_date <= :now_day)) OR (to_status = 'love_fund.enum_participate.not_participated'  AND cancel_date IS NOT NULL AND cancel_date > :now_day)", now_day: Time.zone.now.beginning_of_day)
    end
  }

  scope :by_monthly_deduction, lambda { |amount|
    if amount.to_i == 20
      where("(to_status = 'love_fund.enum_participate.participated' AND (participate_date IS NULL OR participate_date <= :now_day)) OR (to_status = 'love_fund.enum_participate.not_participated'  AND cancel_date IS NOT NULL AND cancel_date > :now_day)", now_day: Time.zone.now.beginning_of_day)
    else
      where.not("(to_status = 'love_fund.enum_participate.participated' AND (participate_date IS NULL OR participate_date <= :now_day)) OR (to_status = 'love_fund.enum_participate.not_participated'  AND cancel_date IS NOT NULL AND cancel_date > :now_day)", now_day: Time.zone.now.beginning_of_day)
    end
  }

  def self.select_with_args(sql, args)
    query = sanitize_sql_array([sql, args].flatten)
    select(query)
  end

end
