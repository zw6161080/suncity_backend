# coding: utf-8
# == Schema Information
#
# Table name: welfare_templates
#
#  id                           :integer          not null, primary key
#  template_chinese_name        :string           not null
#  template_english_name        :string           not null
#  annual_leave                 :integer          not null
#  sick_leave                   :integer          not null
#  office_holiday               :float            not null
#  holiday_type                 :integer          not null
#  probation                    :integer          not null
#  notice_period                :integer          not null
#  double_pay                   :boolean          not null
#  reduce_salary_for_sick       :boolean          not null
#  provide_uniform              :boolean          not null
#  over_time_salary             :integer          not null
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  belongs_to                   :jsonb
#  template_simple_chinese_name :string
#  force_holiday_make_up        :integer
#  salary_composition           :string
#  position_type                :string
#  work_days_every_week         :integer
#
# Indexes
#
#  index_welfare_templates_on_template_chinese_name  (template_chinese_name)
#  index_welfare_templates_on_template_english_name  (template_english_name)
#

class WelfareTemplate < ApplicationRecord
  include StatementAble
  include WelfareTemplateValidators
  validates_with WelfareTemplateValidator
  validates :template_chinese_name, :template_english_name, presence: true, uniqueness: true
  validates :annual_leave, :sick_leave, :office_holiday, :holiday_type, :probation, :over_time_salary, :notice_period,
            :position_type, :work_days_every_week,
            presence: true
  validates :double_pay, :reduce_salary_for_sick,
            :provide_uniform, inclusion: {in: [true, false]}
  validates :salary_composition, inclusion: {in: %w(float fixed)}
  validates :position_type, inclusion: {in: %w(business_staff_48 business_staff_40 non_business_staff_48 non_business_staff_40)}
  validates_numericality_of :work_days_every_week, :in => 5..6
  enum holiday_type: {none_holiday: 0, force_holiday: 1, force_public_holiday: 2}
  enum force_holiday_make_up: {one_money_and_one_holiday: 0, two_money: 1, two_holiday: 2}
  enum over_time_salary: {one_point_two_times: 1, one_point_two_and_two_times: 3}

  def office_holiday
    read_attribute(:office_holiday).to_s.sub(/\.0+$/, '')
  end

  scope :by_annual_leave, lambda { |annual_leave|
    where(annual_leave: annual_leave) if annual_leave
  }
  scope :by_sick_leave, lambda { |sick_leave|
    where(sick_leave: sick_leave) if sick_leave
  }
  scope :by_office_holiday, lambda { |office_holiday|
    where(office_holiday: office_holiday) if office_holiday
  }
  scope :by_holiday_type, lambda { |holiday_type|
    where(holiday_type: holiday_type) if holiday_type
  }
  scope :by_probation, lambda { |probation|
    where(probation: probation) if probation
  }
  scope :by_notice_period, lambda { |notice_period|
    where(notice_period: notice_period) if notice_period
  }
  scope :by_double_pay, lambda { |double_pay|
    where(double_pay: double_pay) if double_pay
  }
  scope :by_reduce_salary_for_sick, lambda { |reduce_salary_for_sick|
    where(reduce_salary_for_sick: reduce_salary_for_sick) if reduce_salary_for_sick
  }
  scope :by_provide_uniform, lambda { |provide_uniform|
    where(provide_uniform: provide_uniform) if provide_uniform
  }
  scope :by_over_time_salary, lambda { |over_time_salary|
    where(over_time_salary: over_time_salary) if over_time_salary
  }
  scope :by_force_holiday_make_up, lambda { |force_holiday_make_up|
    where(force_holiday_make_up: force_holiday_make_up) if force_holiday_make_up
  }
  scope :by_salary_composition, lambda { |salary_composition|
    where(salary_composition: salary_composition) if salary_composition
  }
  scope :by_template_name, lambda { |template_name|
    if (template_name.is_a? Array) && !template_name.empty?
      template_name_for_sql = template_name.map {|val| "%#{val}%" }
      where("template_#{select_language}  ILIKE ANY ( array[:template_name_for_sql]) ", template_name_for_sql: template_name_for_sql)
    end
  }
  scope :by_position_id, lambda { |position_id|
    if (position_id.is_a? Array) && !position_id.empty?
      ids = Department.all.map do |department|
        where("belongs_to -> :department_id ?| array[:position_id]", department_id: department.id.to_s, position_id: position_id).ids
      end
      where(id: ids.flatten.compact)
    end
  }
  scope :by_department_id, lambda { |department_id|
    if (department_id.is_a? Array) && !department_id.empty?
      where("belongs_to ?| array[:department_id]", department_id: department_id)
    end
  }


  scope :order_by, lambda { |sort_column, sort_direction|
    if sort_column.to_sym == :template_name
      order("template_#{select_language}" => sort_direction)
    else
      order(sort_column => sort_direction)

    end
  }


  def validate_result
    self.valid?
    {
      template_name: self.errors[:template_chinese_name].empty? && self.errors[:template_simple_chinese_name].empty? && self.errors[:template_english_name].empty?,
      belongs_to: self.errors[:belongs_to].empty?,
      annual_leave: self.errors[:annual_leave].empty?,
      sick_leave: self.errors[:sick_leave].empty?,
      office_holiday: self.errors[:annual_leave].empty?,
      holiday_type: self.errors[:annual_leave].empty?,
      probation: self.errors[:annual_leave].empty?,
      notice_period: self.errors[:annual_leave].empty?,
      double_pay: self.errors[:annual_leave].empty?,
      reduce_salary_for_sick: self.errors[:annual_leave].empty?,
      provide_uniform: self.errors[:annual_leave].empty?,
      over_time_salary: self.errors[:annual_leave].empty?,
      comment: self.errors[:annual_leave].empty?,
      force_holiday_make_up: self.errors[:annual_leave].empty?,
      salary_composition: self.errors[:annual_leave].empty?,
      position_type: self.errors[:annual_leave].empty?,
      work_days_every_week: self.errors[:annual_leave].empty?,
    }
  end

  def validate_belongs_to
    tag = true
    message = "wrong_department_id_and_position_id: "
    self.belongs_to&.each { |k, v_array|
      department = Department.find(k)
      v_array.each { |v|
        unless department.positions.include? Position.find(v)
          tag = false
          message << "department_id: #{k}, position_id: #{v}"
        end
      }
    }
    {
      tag: tag,
      message: message
    }
  end


  def create_params
    super - :belongs_to
  end

  def belongs_to_string
    string_value = ""
    self.belongs_to&.each { |k, v_array|
      department = Department.find(k)
      v_array.each { |v|
        position = Position.find(v)
        string_value << "#{department.chinese_name}/#{position.chinese_name},"
      }
    }
    string_value.sub(/\,$/, '')
  end
end
