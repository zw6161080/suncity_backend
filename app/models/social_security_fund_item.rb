# == Schema Information
#
# Table name: social_security_fund_items
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  year_month                :datetime
#  employee_payment_mop      :decimal(10, 2)
#  company_payment_mop       :decimal(10, 2)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  career_entry_date         :datetime
#  employee_type             :string
#  employment_status         :string
#  department_id             :integer
#  position_id               :integer
#  position_resigned_date    :datetime
#  date_to_submit_fingermold :datetime
#  cancel_date               :datetime
#  company_name              :string
#  gender                    :string
#  date_of_birth             :datetime
#  tax_declare_date          :datetime
#  type_of_id                :string
#  id_number                 :string
#  sss_number                :string
#  tax_number                :string
#
# Indexes
#
#  index_social_security_fund_items_on_department_id  (department_id)
#  index_social_security_fund_items_on_position_id    (position_id)
#  index_social_security_fund_items_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_ca033795a5  (user_id => users.id)
#

class SocialSecurityFundItem < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :department
  belongs_to :position
  enum employee_type: {
    local_employee: 'local_employee',
    nonlocal_employee: 'nonlocal_employee'
  }

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
    order('year_month desc, users.empoid asc')
  }

  scope :by_year_month, -> (year_month) {
    where(year_month: Time.zone.parse(year_month).month_range)
  }

  scope :by_year, lambda {|year|
    where("extract(year from year_month AT TIME ZONE 'cst +08:00') = :year", year: year) if year
  }

  scope :by_month, lambda {|month|
    where("extract(month from year_month AT TIME ZONE 'cst +08:00') = :month", month: month) if month
  }

  scope :order_year, lambda {|direction|
    order("year_month #{direction.first}")
  }

  scope :order_month, lambda {|direction|
    select("social_security_fund_items.*, extract(month from year_month AT TIME ZONE 'cst +08:00') as month").order("month #{direction.first}")
  }

  scope :order_resigned_date, lambda {|direction|
    if direction == :desc
      order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
    else
      order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
    end
  }

  class << self
    def extra_joined_association_names
      [{user: :card_profile}]
    end

    def extra_query_params
      [ { key: 'year_month' } ]
    end

    def year_options
      self.select("extract(year from year_month AT TIME ZONE 'cst +08:00') as year").map{|item| item['year']}.sort.uniq.map do |item|
        {
          key: item,
          chinese_name: item,
          english_name: item,
          simple_chinese_name: item
        }
      end
    end

    def month_options
      self.select("extract(month from year_month AT TIME ZONE 'cst +08:00') as month").map{|item| item['month']}.sort.uniq.map do |item|
        {
          key: item,
          chinese_name: item,
          english_name: item,
          simple_chinese_name: item
        }
      end
    end

    def year_month_options
      self.select(:year_month).distinct.pluck(:year_month)
    end

    def generate_all(year_month_date)
      User.all.where(id: ProfileService.users1(year_month_date).ids).where.not(id: ProfileService.users2(year_month_date).ids ).find_each do |user|
        generate(user, year_month_date)
      end
    end

    def generate(user, year_month_date)
      calc_params = self.create_params - %w(user_id year_month)
      year_month = year_month_date.beginning_of_month
      self
        .where(user: user, year_month: year_month..year_month.end_of_month)
        .first_or_create(user_id: user.id, year_month: year_month)
        .update(
          calc_params.map { |param|
            [param, self.send("calc_#{param}", user, year_month)]
          }.to_h
        )
    end


    def calc_employment_status(user, year_month)
      ProfileService.employment_status(user, year_month.end_of_month.beginning_of_day)
    end

    def calc_department_id(user, year_month)
      ProfileService.department(user, year_month.end_of_month.beginning_of_day).id
    end

    def calc_position_id(user, year_month)
      ProfileService.position(user, year_month.end_of_month.beginning_of_day).id
    end

    def calc_position_resigned_date(user, year_month)
      ProfileService.resigned_date(user)
    end

    def calc_date_to_submit_fingermold(user, year_month)
      user&.card_profile&.date_to_submit_fingermold
    end

    def calc_cancel_date(user, year_month)
      user&.card_profile&.cancel_date
    end

    def calc_company_name(user, year_month)
    ProfileService.company_name(user, year_month.end_of_month.beginning_of_day)
    end

    def calc_id_number(user, year_month)
      user.profile.data['personal_information']['field_values']['id_number']
    end

    def calc_sss_number(user, year_month)
      user.profile.data['personal_information']['field_values']['sss_number']
    end

    def calc_gender(user, year_month)
      user.profile.data['personal_information']['field_values']['gender']
    end

    def calc_date_of_birth(user, year_month)
      user.profile.data['personal_information']['field_values']['date_of_birth']
    end

    def calc_tax_declare_date(user, year_month)
      user.profile.data['personal_information']['field_values']['tax_declare_date']
    end


    def calc_type_of_id(user, year_month)
      user.profile.data['personal_information']['field_values']['type_of_id']
    end

    def calc_tax_number(user, year_month)
      user.profile.data['personal_information']['field_values']['tax_number']
    end


    def calc_employee_payment_mop(user, year_month)
      # 是否本地雇员
      is_local = !ProfileService.whether_foreign_employee(user)
      # 是否兼职
      is_part_time = user.profile&.is_part_time_staff?
      # 是否工作满15天
      is_working_more_than_15_days = ProfileService.work_days_in_this_month(user,year_month) >= 15 rescue false
      settings = Config.get('social_security_fund_settings')

      # 本地 全职
      if is_local && !is_part_time
        # 工作日  > 15 ? 30 : 0
        return is_working_more_than_15_days ?
          settings['local_fulltime_more_than_15_days_employee_payment_mop'] :
          settings['local_fulltime_less_than_15_days_employee_payment_mop']
      end

        # 本地 兼职
      if is_local && is_part_time
        # # 工作日  > 15 ? 30 : 15
        return is_working_more_than_15_days ?
          settings['local_parttime_more_than_15_days_employee_payment_mop'] :
          settings['local_parttime_less_than_15_days_employee_payment_mop']
      end

      if !is_local
        # 外地
        return settings['nonlocal_employee_payment_mop']
      end

      nil
    end

    def calc_company_payment_mop(user, year_month)
      # 是否本地雇员
      is_local = !ProfileService.whether_foreign_employee(user)
      # 是否兼职
      is_part_time = user.profile&.is_part_time_staff?
      # 是否工作满15天
      work_days_in_this_month = ProfileService.work_days_in_this_month(user,year_month)
      is_working_more_than_15_days = work_days_in_this_month >= 15 rescue false

      settings = Config.get('social_security_fund_settings')
      # 本地 不是兼职
      if is_local && !is_part_time
        # 本地 不是兼职 满15天 ？ 60 ： 0
        return is_working_more_than_15_days ?
          settings['local_fulltime_more_than_15_days_company_payment_mop'] :
          settings['local_fulltime_less_than_15_days_company_payment_mop']
      end

        # 本地 兼职
      if is_local && is_part_time
        # 本地 兼职 满15天 ？ 60： 30
        return is_working_more_than_15_days ?
          settings['local_parttime_more_than_15_days_company_payment_mop'] :
          settings['local_parttime_less_than_15_days_company_payment_mop']
        # 外地的
      end

      if !is_local
        # 有工作日 ？ 200 ： 0
        return work_days_in_this_month > 0 ?
          settings['nonlocal_entry_after_15_day_of_month_company_payment_mop'] :
          settings['nonlocal_entry_before_15_day_of_month_company_payment_mop']
      end

      nil
    end

    def calc_career_entry_date(user, year_month)
      user.career_entry_date
    end

    def calc_employee_type(user, year_month)
      user.profile&.is_local_employee? ? 'local_employee' : 'nonlocal_employee'
    end

  end

end
