# == Schema Information
#
# Table name: month_salary_change_records
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  original_salary_record_id :integer
#  updated_salary_record_id  :integer
#
# Indexes
#
#  index_month_salary_change_records_on_original_salary_record_id  (original_salary_record_id)
#  index_month_salary_change_records_on_updated_salary_record_id   (updated_salary_record_id)
#  index_month_salary_change_records_on_user_id                    (user_id)
#
# Foreign Keys
#
#  fk_rails_5f91944d37  (original_salary_record_id => salary_records.id)
#  fk_rails_9379decdc7  (updated_salary_record_id => salary_records.id)
#  fk_rails_bc08568640  (user_id => users.id)
#

class MonthSalaryChangeRecord < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :original_salary_record, :class_name => 'SalaryRecord', :foreign_key => 'original_salary_record_id'
  belongs_to :updated_salary_record, :class_name => 'SalaryRecord', :foreign_key => 'updated_salary_record_id'

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid              then order("users.empoid #{sort_direction}")
      when :name                then order("users.chinese_name #{sort_direction}")
      when :location            then order("users.location_id #{sort_direction}")
      when :department          then order("users.department_id #{sort_direction}")
      when :position            then order("users.position_id #{sort_direction}")
      when :grade               then order("users.grade #{sort_direction}")
      when :date_of_employment  then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
        end
      when :salary_begin        then order("salary_records.salary_begin #{sort_direction}")
      when :leave_date          then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, resigned_date}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, resigned_date}' ")
        end
    end
  }

  scope :by_company_name, lambda {|company_name|
    where(users: { company_name: company_name }) if company_name
  }

  scope :by_location, lambda {|location_id|
    where(users: { location_id: location_id }) if location_id
  }

  scope :by_position, lambda {|position_id|
    where(users: { position_id: position_id }) if position_id
  }

  scope :by_department, lambda {|department_id|
    where(users: { department_id: department_id }) if department_id
  }

  scope :by_salary_begin, lambda {|salary_begin|
    from = Time.zone.parse(salary_begin[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(salary_begin[:end]).end_of_day rescue nil
    if from && to
      where("salary_records.salary_begin >= :from", from: from).where("salary_records.salary_begin <= :to", to: to)
    elsif from
      where("salary_records.salary_begin >= :from", from: from)
    elsif to
      where("salary_records.salary_begin <= :to", to: to)
    end
  }

  class << self
    def joined_query(param_id = nil)
      self.left_outer_joins([])
    end
  end
end
