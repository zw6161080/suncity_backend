namespace :migrate_data do
  desc '加载所有预定义的数据'

  task load_predefined: :environment do
    puts 'Load Region Predefined'
    Region.load_predefined

    puts 'Load Select Column Template Predefined'
    SelectColumnTemplate.load_predefined

    puts 'Load Locations Predefined'
    Location.load_predefined

    puts 'Load Departments Predefined'
    ceo_department = Department.load_predefined

    puts 'Load Positions Predefined'
    ceo_position = Position.load_predefined

    puts 'Set Departments & Locations for Position'
    unless ceo_position.departments.exists?(ceo_department)
      ceo_position.departments << ceo_department
      ceo_position.save!
    end

    unless ceo_position.locations.exists?(Location.find_by_location_type(:office))
      ceo_position.locations << Location.find_by_location_type(:office)
      ceo_position.save!
    end

    puts 'Load Roles Predefined'
    admin_role = Role.load_predefined

    puts 'Load Admin'
    admin_user = create_admin_user('90000001', 'Admin', Location.first.id, Position.first.id, Department.first.id)
    admin_role.add_user(admin_user)

    puts 'Load Report predefined'
    Report.load_predefined

    puts 'Load BonusElement predefined'
    BonusElement.load_predefined

    puts 'Load OccupationTaxSetting predefined'
    OccupationTaxSetting.load_predefined

    puts 'Load SalaryElementCategory predefined'
    SalaryElementCategory.load_predefined

    puts 'Load MedicalTemplateSetting predefined'
    MedicalTemplateSetting.load_predefined

    puts 'Load AppraisalBasicSetting predefined'
    AppraisalBasicSetting.load_predefined

    puts 'Load AppraisalDepartmentSetting predefined'
    AppraisalDepartmentSetting.create_all_related_settings

    puts 'Load AppraisalEmployeeSetting predefined'
    AppraisalEmployeeSetting.generate

    puts 'Load SalaryColumn'
    SalaryColumn.generate

    puts 'Load SalaryColumnTemplate'
    SalaryColumnTemplate.load_predefined

    puts 'Generate Taken Holiday Record'
    # TakenHolidayRecord.generate_taken_holiday_records

    puts 'Generate Force Holiday Working Record'
    # ForceHolidayWorkingRecord.load_force_holiday_date_and_user

    puts 'Finished'
  end
end


def create_admin_user(empoid, name, location_id, position_id, department_id)
  if User.where(empoid: empoid).exists?
    return User.find_by_empoid(empoid)
  end

  sections_hash = [
    {
      "field_values" => {
        "gender" => "male",
        "address" => "北京",
        "national" => "macau",
        "id_number" => "111111",
        "type_of_id" => "macau_permanent_identity_card",
        "chinese_name" => name,
        "english_name" => name,
        "date_of_birth" => "1111/11/11",
        "mobile_number" => "111111",
        "date_of_expiry" => "2020/12/31",
        "marital_status" => "unmarried",
        "place_of_birth" => "北京"
      },
      "key" => "personal_information"
    }, {
      "field_values" => {
        "grade" => "1",
        "empoid" => empoid,
        "location" => location_id,
        "position" => position_id,
        "department" => department_id,
        "company_name" => "suncity_gaming_promotion_company_limited",
        "division_of_job" => "front_office",
        "employment_status" => "informal_employees",
        "date_of_employment" => "2017/05/16",
        "suncity_charity_join_date" => "2017/05/16",
        "seniority_calculation_date" => "2017/05/16",
        "suncity_charity_fund_status" => true
      },
      "key" => "position_information"
    }
  ]

  ret = nil
  ActiveRecord::Base.transaction do
    user = User.new
    user.password = '123456'
    user.save!

    the_profile = user.build_profile
    the_profile.sections = Profile.fork_template(region: 'macau', params: sections_hash)
    the_profile.is_stashed = false
    the_profile.save!
    params = {
      welfare_begin: Time.zone.now.beginning_of_day,
      change_reason: 'entry',
      annual_leave: 2,
      sick_leave: 2,
      office_holiday: 2,
      holiday_type: 'none_holiday',
      probation: 30,
      notice_period: 30,
      double_pay: true,
      reduce_salary_for_sick: false,
      provide_uniform: true,
      salary_composition: 'float',
      over_time_salary: 'one_point_two_times',
      force_holiday_make_up: 'one_money_and_one_holiday',
      user_id: user.id,
    }
    wr = WelfareRecord.create(params)
    params = {
      salary_begin: Time.zone.now.beginning_of_day,
      change_reason: 'entry',
      basic_salary: '10',
      bonus: '10',
      attendance_award: '10',
      house_bonus: '10',
      new_year_bonus: '10',
      project_bonus: '10',
      product_bonus: '10',
      tea_bonus: '10',
      kill_bonus: '10',
      performance_bonus: '10',
      charge_bonus: '10',
      commission_bonus: '10',
      receive_bonus: '10',
      exchange_rate_bonus: '10',
      guest_card_bonus: '10',
      respect_bonus: '10',
      region_bonus: '10',
      user_id: user.id,
    }
    SalaryRecord.create(params)

    wrwt = Wrwt.create(
      user_id: user.id,
      provide_airfare: true,
      provide_accommodation: true,
      airfare_type: 'count',
      airfare_count: 1,
    )


    CareerRecord.create_initial_record(
      {user_id: user.id,
       trial_period_expiration_date: Time.zone.now + ActiveModelSerializers::SerializableResource.new(wr).serializer_instance.probation.days,
       company_name: user.company_name, location_id: location_id, position_id: position_id,
       department_id: department_id, grade: user.grade,
       division_of_job: the_profile.data['position_information']['field_values']['division_of_job'],
       employment_status: the_profile.data['position_information']['field_values']['employment_status'],
       inputer_id: user.id,
       career_begin: the_profile.data['position_information']['field_values']['date_of_employment']
      }
    )


    ret = user
  end
  ret
end