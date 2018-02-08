class FloatSalaryMonthEntrySerializer < ActiveModel::Serializer
  attributes *FloatSalaryMonthEntry.column_names , :locations_with_departments
  def locations_with_departments
    unless object.status == 'generating'
      LocationStatus.where(float_salary_month_entry_id: object.id).as_json.map do |location_status|
        location = Location.find(location_status['location_id'])
        departments = Department.where(id: LocationDepartmentStatus.where(location_id: location_status['location_id'], float_salary_month_entry_id: object.id).map{|item| item['department_id']}.compact).as_json
        res = location_status.merge(location.as_json).merge(departments: departments).as_json
        res['employees_total'] = BigDecimal(res['employees_on_duty']) + BigDecimal(res['employees_left_this_month'])
        res
      end.map do |item|
        item['departments'] = item['departments'].map do |department|
          res =  department.merge(LocationDepartmentStatus.where(department_id: department['id'], location_id: item['location_id'], float_salary_month_entry_id: object.id).first.as_json.reject {|key|key == 'id'})
          res['employees_total'] = BigDecimal(res['employees_on_duty']) + BigDecimal(res['employees_left_this_month'])
          res
        end
        item
      end
    end
  end
end
