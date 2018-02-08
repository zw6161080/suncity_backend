# == Schema Information
#
# Table name: pay_slips
#
#  id                    :integer          not null, primary key
#  year_month            :datetime
#  salary_begin          :datetime
#  salary_end            :datetime
#  user_id               :integer
#  entry_on_this_month   :boolean
#  leave_on_this_month   :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  comment               :string
#  salary_type           :string
#  resignation_record_id :integer
#
# Indexes
#
#  index_pay_slips_on_user_id  (user_id)
#

class PaySlip < ApplicationRecord
  include StatementAble
  belongs_to :user
  validates :salary_type, inclusion: {in: %w(on_duty left)}

  scope :by_action_and_year_month_on_pay_slips, lambda{
    where("(pay_slips.resignation_record_id = salary_values.resignation_record_id) OR( pay_slips.year_month =  salary_values.year_month AND pay_slips.salary_type = salary_values.salary_type )")
  }

  scope :joins_user, lambda {
    joins(user: [:department, :position, :location])
  }

  scope :by_year_month, lambda{|year_month|
    where(year_month: year_month.map{|year_month|
      Time.zone.parse(year_month) }) if year_month
  }

  scope :by_salary_begin, lambda{|salary_begin_begin, salary_begin_end|
    if salary_begin_begin && salary_begin_end
      where(salary_begin: salary_begin_begin...salary_begin_end)
    elsif salary_begin_begin
      where('salary_begin > :salary_begin_begin', salary_begin_begin: salary_begin_begin)
    elsif salary_begin_end
      where('salary_begin < :salary_begin_end', salary_begin_end: salary_begin_end)
    end
  }

  scope :by_salary_end, lambda{|salary_end_begin, salary_end_end|
    if salary_end_begin && salary_end_end
      where(salary_end: salary_end_begin...salary_end_end)
    elsif salary_end_begin
      where('salary_end > :salary_end_begin', salary_end_begin: salary_end_begin)
    elsif salary_end_end
      where('salary_end < :salary_end_end', salary_end_end: salary_end_end)
    end
  }

  scope :by_name, lambda{|name|
    if name
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 2})
        .where("salary_values.object_value ->> '"+"#{select_language}"+"' = :name", name: name)
    end
  }

  scope :by_empoid, lambda {|empoid|
    if empoid
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 1})
        .where(salary_values: {string_value: empoid})
    end
  }

  scope :by_company_name, lambda {|company_name|
    if company_name
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 5})
        .where("salary_values.object_value ->> 'key' in  ("+ company_name.map {|item| "'#{item}'"}.join(',') +")")
    end
  }

  scope :by_department_id, lambda {|department_id|
    if department_id
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 7})
        .where("(salary_values.object_value ->> 'id')::int in ("+ department_id.map {|item| "#{item}"}.join(',') +")")
    end
  }

  scope :by_position_id, lambda {|position_id|
    if position_id
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 152})
        .where("(salary_values.object_value ->> 'id') in ("+ position_id.map {|item| "#{item}"}.join(',') +")")
    end
  }

  scope :by_location_id, lambda {|location_id|
    if location_id
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 6})
        .where("(salary_values.object_value ->> 'id')::int in ("+ location_id.map {|item| "#{item}"}.join(',') +")")
    end
  }

  scope :by_grade, lambda {|grade|
    if grade
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 9})
        .where(salary_values: {integer_value: grade})
    end
  }

  scope :by_entry_on_this_month, lambda {|entry_on_this_month|
    where(entry_on_this_month: entry_on_this_month) if entry_on_this_month
  }

  scope :by_leave_on_this_month, lambda {|leave_on_this_month|
    where(leave_on_this_month: leave_on_this_month) if leave_on_this_month
  }

  scope :by_order, lambda {|sort_column, sort_direction|
    if sort_column == :default_order
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 1}).order("pay_slips.year_month desc, salary_values.string_value asc")
    elsif sort_column == :empoid
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 1}).order("salary_values.string_value #{sort_direction}")
    elsif sort_column == :name
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 2}).order("salary_values.object_value ->> '"+"#{select_language}"+"' #{sort_direction}")
    elsif sort_column == :department_id
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 8}).order("salary_values.object_value ->> '"+"id"+"' #{sort_direction}")
    elsif sort_column == :position_id
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 152}).order("salary_values.object_value ->> '"+"id"+"' #{sort_direction}")
    elsif sort_column == :location_id
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 6}).order("salary_values.object_value ->> '"+"id"+"' #{sort_direction}")
    elsif sort_column == :company_name
      joins(user: :salary_values).by_action_and_year_month_on_pay_slips
        .where(salary_values: {salary_column_id: 5}).order("salary_values.object_value ->> '"+"key"+"' #{sort_direction}")
    else
      order(sort_column => sort_direction)
    end
  }


  def get_grade
    if self.resignation_record_id
      SalaryValue.where(resignation_record_id: self.resignation_record_id, salary_column_id: 9, user_id: self.user_id).first&.integer_value
    else
      SalaryValue.where(salary_type: self.salary_type, year_month: self.year_month, salary_column_id: 9,  user_id: self.user_id).first&.integer_value
    end
  end

  def without_grade_limition?
    [3,4,5,6].include? get_grade
  end

  class << self
    def department_options
      self.joins(user: :salary_values)
        .where(salary_values: {salary_column_id: 7}).where('object_value is not null')
        .select("salary_values.object_value as department").distinct.map{|item| item['department']}
    end

    def location_options
      self.joins(user: :salary_values)
        .where(salary_values: {salary_column_id: 6}).where('object_value is not null')
        .select("salary_values.object_value as location").distinct.map{|item| item['location']}
    end

    def position_options
      self.joins(user: :salary_values)
        .where(salary_values: {salary_column_id: 152}).where("object_value is not null AND object_value ->> 'id' is not null")
        .distinct.map{|item| item['position']}.compact.select{|item| item['id']}

    end
  end

  def self.year_month_options
    self.select(:year_month).distinct.map do |record|
      {
        key: record.year_month,
        chinese_name: I18n.l(record.year_month, format: '%Y/%m', locale: :'zh-CN'),
        english_name_: I18n.l(record.year_month, format: '%Y/%m', locale: :'zh-HK'),
        simple_chinese_name: I18n.l(record.year_month, format: '%Y/%m', locale: :'en')
      }
    end
  end
end
