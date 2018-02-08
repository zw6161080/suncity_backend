# == Schema Information
#
# Table name: department_statuses
#
#  id                          :integer          not null, primary key
#  year_month                  :datetime
#  employees_on_duty           :integer
#  employees_left_this_month   :integer
#  employees_left_last_day     :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  department_id               :integer
#  float_salary_month_entry_id :integer
#
# Indexes
#
#  index_department_statuses_on_department_id                (department_id)
#  index_department_statuses_on_float_salary_month_entry_id  (float_salary_month_entry_id)
#

class DepartmentStatus < ApplicationRecord
  belongs_to :department
  belongs_to :float_salary_month_entry

  def self.create_with_params(year_month, float_salary_month_entry_id)
    year_month = year_month.beginning_of_month
    #users3: 这个月离职员工
    users3 = ProfileService.users3(year_month)
    #users4: 在职员工
    users4 = ProfileService.users4(year_month)
    #users5: 这个月最后一天离职的员工
    users5 = ProfileService.users5(year_month)
    Department.all.each do |department|
      DepartmentStatus.create(
        year_month: year_month.beginning_of_month,
        employees_on_duty: users4.where(department_id: department.id).count,
        employees_left_this_month: users3.where(department_id: department.id).count,
        employees_left_last_day: users5.where(department_id: department.id).count,
        department_id: department.id, float_salary_month_entry_id: float_salary_month_entry_id)
    end
  end
end
