# == Schema Information
#
# Table name: location_department_statuses
#
#  id                          :integer          not null, primary key
#  year_month                  :datetime
#  employees_on_duty           :integer
#  employees_left_this_month   :integer
#  employees_left_last_day     :integer
#  location_id                 :integer
#  department_id               :integer
#  float_salary_month_entry_id :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  department_float_salary_month_entry_index            (float_salary_month_entry_id)
#  index_location_department_statuses_on_department_id  (department_id)
#  index_location_department_statuses_on_location_id    (location_id)
#

class LocationDepartmentStatus < ApplicationRecord
  belongs_to :location
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

    Location.list.each do |location|
      location.departments.without_suncity_department.each do |department|
         LocationDepartmentStatus.create(
          year_month: year_month.beginning_of_month,
          employees_on_duty: users4.where(location_id: location.id, department_id: department.id).count,
          employees_left_this_month: users3.where(location_id: location.id, department_id: department.id).count,
          employees_left_last_day: users5.where(location_id: location.id, department_id: department.id).count,
          location_id: location.id,
          department_id: department.id,
          float_salary_month_entry_id: float_salary_month_entry_id)
      end
    end
  end
end
