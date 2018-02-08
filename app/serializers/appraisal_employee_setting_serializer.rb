class AppraisalEmployeeSettingSerializer < ActiveModel::Serializer
  attributes :id,
             :has_finished,
             :user,
             :level_in_department,
             :division_of_job,
             :working_status,
             :whether_group_inside,
             :appraisal_grade_quantity_inside,
             :appraisal_group_id,
             :groups

  def groups
    object.appraisal_department_setting.appraisal_groups
  end

  def appraisal_grade_quantity_inside
    object.appraisal_department_setting.appraisal_grade_quantity_inside
    end

  def whether_group_inside
    object.appraisal_department_setting.whether_group_inside
  end

  def working_status
    option = {
      'on_duty': {
        key: 'on_duty',
        chinese_name: '在職',
        english_name: 'on_duty',
        simple_chinese_name: '在职',
      },
      'leave': {
        key: 'leave',
        chinese_name: '離職',
        english_name: 'Turnover',
        simple_chinese_name: '离职',
      }
    }
    option[ProfileService.is_leave?(object.user) ? :leave : :on_duty]
  end

  def user
    object.user.as_json(include: [:location, :department, :position])
  end

  def division_of_job
    option = {
      'front_office': {
        key: 'front_office',
        chinese_name: '前線',
        english_name: 'Front Office',
        simple_chinese_name: '前线'
      },
      'back_office': {
        key: 'back_office',
        chinese_name: '後勤',
        english_name: 'Back Office',
        simple_chinese_name: '后勤'}
    }
    option[object.user.profile.data['position_information']['field_values']['division_of_job'].to_sym]
  end

end
