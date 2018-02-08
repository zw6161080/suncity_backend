# == Schema Information
#
# Table name: employee_redemption_report_items
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  contribution_item  :string
#  vesting_percentage :decimal(, )
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_employee_redemption_report_items_on_user_id  (user_id)
#

class EmployeeRedemptionReportItem < ApplicationRecord
  include StatementAble
  belongs_to :user

  def resigned_date
    ProfileService.resigned_date(self.user)  rescue nil
  end

  def resigned_reason
    self.user.resignation_records.where(status: :being_valid).first&.resigned_reason
  end


  scope :by_chinese_name, -> (name) {
    where('users.chinese_name = :name', name: name)
  }

  scope :by_english_name, -> (name) {
    where('users.english_name = :name' , name: name)
  }

  scope :order_chinese_name, -> (sort_direction) {
    order("users.chinese_name #{sort_direction.first}")
  }

  scope :order_english_name, -> (sort_direction) {
    order("users.english_name #{sort_direction.first}")
  }


  scope :order_default, lambda{
    order('provident_funds.provident_fund_resignation_date asc, users.empoid asc')
  }

  scope :by_provident_fund_resignation_date, lambda {|value|
    begin_date = (Time.zone.parse(value['begin']) rescue nil)
    end_date = (Time.zone.parse(value['end']) rescue nil)
    if begin_date && end_date
      where("provident_funds.provident_fund_resignation_date >= :begin_date AND provident_funds.provident_fund_resignation_date <= :end_date", begin_date: begin_date, end_date: end_date)
    elsif begin_date
      where("provident_funds.provident_fund_resignation_date >= :begin_date", begin_date: begin_date)
    elsif end_date
      where(" provident_funds.provident_fund_resignation_date <= :end_date", end_date: end_date)
    end
  }

  scope :by_resigned_date, lambda {|value|
    begin_date = (Time.zone.parse(value['begin']) rescue nil)
    end_date = (Time.zone.parse(value['end']) rescue nil)
    left_outer_joins(user: :resignation_records).where(resignation_records: {status: :being_valid})
      .where("resignation_records.resigned_date >= :begin_date AND resignation_records.resigned_date <= :end_date", begin_date: begin_date, end_date: end_date)
  }

  scope :by_resigned_reason, lambda {|value|
    left_outer_joins(user: :resignation_records).where(resignation_records: {status: :being_valid})
      .where("resignation_records.resigned_reason IN ("+value.map{|item| "'#{item}'"}.join(',') + ")")
  }

  scope :order_resigned_date, lambda {|sort_direction|
    left_outer_joins(user: :resignation_records).where(resignation_records: {status: :being_valid})
      .order("resignation_records.resigned_date #{sort_direction.first}")
  }

  scope :order_resigned_reason, lambda {|sort_direction|
    left_outer_joins(user: :resignation_records).where(resignation_records: {status: :being_valid})
      .order("resignation_records.resigned_reason #{sort_direction.first} ")
  }


  class << self

    def extra_joined_association_names
      [{user: [{profile: :provident_fund}, :resignation_records]}]
    end
    def generate_all
      User.all.find_each do |user|
        generate(user)
      end
    end

    def generate(user)
      self
          .where(user: user)
          .create(user_id: user.id, contribution_item: 'employer_contribution',vesting_percentage: calcu_vesting_percentage(user) )
      self
          .where(user: user)
          .create(user_id: user.id, contribution_item: 'membership_contribution', vesting_percentage: BigDecimal(1))
      self
          .where(user: user)
          .create(user_id: user.id, contribution_item: 'employee_voluntary_contribution', vesting_percentage: BigDecimal(0))
      self
          .where(user: user)
          .create(user_id: user.id, contribution_item: 'employer_voluntary_contribution', vesting_percentage: BigDecimal(0))

    end

    private
    def calcu_vesting_percentage(user)
      resignation_record = user.resignation_records.order(created_at: :desc).first
      if resignation_record
        if resignation_record.resigned_reason == 'retirement'
          BigDecimal.new(1)
        elsif resignation_record.resigned_reason == 'termination'
          BigDecimal.new(0)
        else
          years = ProfileService.work_years(user)
          if  years < 3
            BigDecimal(0)
          elsif years >=3 && years < 4
            BigDecimal('0.3')
          elsif years >=4 && years < 5
            BigDecimal('0.4')
          elsif years >=5 && years < 6
            BigDecimal('0.5')
          elsif years >=6 && years < 7
            BigDecimal('0.6')
          elsif years >=7 && years < 8
            BigDecimal('0.7')
          elsif years >=8 && years < 9
            BigDecimal('0.8')
          elsif years >=9 && years < 10
            BigDecimal('0.9')
          elsif years >=10
            BigDecimal(1)
          end
        end
      else
        BigDecimal.new(0)
      end
    end
  end
end
