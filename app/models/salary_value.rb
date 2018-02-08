# == Schema Information
#
# Table name: salary_values
#
#  id                    :integer          not null, primary key
#  string_value          :string
#  integer_value         :integer
#  date_value            :datetime
#  user_id               :integer
#  object_value          :jsonb
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  salary_column_id      :integer
#  year_month            :datetime
#  salary_type           :string
#  boolean_value         :boolean
#  resignation_record_id :integer
#  decimal_value         :decimal(30, 4)
#
# Indexes
#
#  index_salary_values_on_resignation_record_id  (resignation_record_id)
#  index_salary_values_on_salary_column_id       (salary_column_id)
#  index_salary_values_on_user_id                (user_id)
#

class SalaryValue < ApplicationRecord
  include UserSortAble
  include SalaryValueValidators
  validates :salary_type, inclusion: {in: %w(on_duty left)}
  validates_with SalaryValueUniquenessValidator
  belongs_to :user
  belongs_to :salary_column
  belongs_to :resignation_record
  # has_one :

  scope :by_order, lambda{|sort_column, sort_direction, action, year_month|
    if sort_column == :all_month_salary_default
      order('year_month desc, users.empoid asc')
    elsif sort_column == :all_left_month_salary_default
      order('string_value desc, year_month desc, users.empoid asc')
    elsif sort_column == :'1'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 1}).order("salary_values_users.string_value #{sort_direction}")
    elsif sort_column == :'2'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 2}).order("salary_values_users.object_value ->> '"+"#{select_language}"+"' #{sort_direction}")
    elsif sort_column == :'6'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 6}).order("salary_values_users.object_value ->> '"+"id"+"' #{sort_direction}")
    elsif sort_column == :'7'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 7}).order("salary_values_users.object_value ->> '"+"id"+"' #{sort_direction}")
    elsif sort_column == :'8'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 8}).order("salary_values_users.object_value ->> '"+"id"+"' #{sort_direction}")
    elsif sort_column == :'5'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 5}).order("salary_values_users.object_value ->> '"+"key"+"' #{sort_direction}")
    elsif sort_column == :'9'
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 9}).order("salary_values_users.integer_value #{sort_direction}")
    elsif sort_column == :'3' || sort_column == :'4'
      order(:year_month => sort_direction)
    elsif sort_column == :'0'
      order(:string_value => sort_direction)
    else
      order(sort_column => sort_direction)
    end
  }

  scope :by_action_and_year_month_on_salary_values_users, lambda{|action, year_month|
    if action == :on_duty
      where(salary_values_users: {year_month: year_month, salary_type: :on_duty})
    elsif action == :left
      where(salary_values_users: {salary_type: :left}).where("salary_values_users.resignation_record_id = salary_values.resignation_record_id")
    else
      where("(salary_values_users.resignation_record_id = salary_values.resignation_record_id) OR (salary_values_users.year_month =  salary_values.year_month AND salary_values_users.salary_type = salary_values.salary_type)")
    end
  }



  scope :by_action_and_year_month, lambda{|action, year_month|
    if action == :on_duty
      where(year_month: year_month, salary_type: :on_duty)
    elsif action == :left
      where(salary_type: :left)
    end
  }


  scope :by_empoid, lambda {|empoid, action, year_month |
    if empoid
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 1})
        .where(salary_values_users: {string_value: empoid})
    end
  }

  scope :by_name, lambda{|name, action, year_month |
    if name
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 2})
        .where("salary_values_users.object_value ->> '"+"#{select_language}"+"' = :name", name: name)
    end
  }

  scope :by_company_name, lambda {|company_name, action, year_month |
    if company_name
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 5})
        .where("salary_values_users.object_value ->> 'key' in  ("+ company_name.map {|item| "'#{item}'"}.join(',') +")")
    end
  }

  scope :by_location_id, lambda {|location_id, action, year_month |
    if location_id
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 6})
        .where("(salary_values_users.object_value ->> 'id')::int in ("+ location_id.map {|item| "#{item}"}.join(',') +")")
    end
  }
  scope :by_position_id, lambda {|position_id, action, year_month |
    if position_id
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 8})
        .where("(salary_values_users.object_value ->> 'id')::int in ("+ position_id.map {|item| "#{item}"}.join(',') +")")
    end
  }
  scope :by_department_id, lambda {|department_id, action, year_month |
    if department_id
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 7})
        .where("(salary_values_users.object_value ->> 'id')::int in ("+ department_id.map {|item| "#{item}"}.join(',') +")")
    end
  }
  scope :by_grade, lambda {|grade, action, year_month |
    if grade
      joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month)
        .where(salary_values_users: {salary_column_id: 9})
        .where(salary_values_users: {integer_value: grade})
    end
  }

  scope :by_year, lambda{ |year|
    if year
      params_array_item = year.map{|item|
        year_begin = Time.zone.parse("#{item}/01")
        year_end = year_begin.end_of_year
        [year_begin, year_end]
      }.flatten
      sql = ['salary_values.year_month >= ? AND salary_values.year_month <= ? ' * year.count, params_array_item ].flatten
      where(sql)
    end
  }

  scope :by_month, lambda{ |month|
    where("extract(month from salary_values.year_month AT TIME ZONE 'cst +08:00') in (" + month.map{|item| item.to_s}.join(',') + ")") if month
  }

  scope :by_status, lambda {|status|
    where("string_value in (" + status.map{|item| "'#{item}'"}.join(',') + ")") if status
  }

  def update_value(value)
    ActiveRecord::Base.transaction do
      self.update_columns("#{self.salary_column.value_type}_value" => value)
      Rails.cache.write(SalaryCalculatorService.cache_key_prefix_by_year_month(self.user, self.year_month, self.salary_column.function.match(/[^[calc_]]\w+/).to_s, self.resignation_record_id), value)
      SalaryCalculatorService.update_add_columns(self.year_month, self.user, self.resignation_record_id) if [170, 185, 189, 194, 196, 213, 216, 217].include? self.salary_column_id
      value
    end
  end
end
