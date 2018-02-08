require "test_helper"

class SalaryValues218Test < ActionDispatch::IntegrationTest
  setup do
    OccupationTaxSetting.load_predefined
    User.destroy_all
    SalaryColumn.generate

    current_user = create(:user)
    single_location = create(:location, id: 100)
    single_department = create(:department, id: 13)
    single_location.departments << single_department
    single_department.positions << create(:position, id: 12)
    single_department.positions << create(:position, id: 11)

    ProfilesController.any_instance.stubs(:current_user).returns(current_user)
    ProfilesController.any_instance.stubs(:authorize).returns(true)
    @first_welfare_template = create(
      :welfare_template, template_chinese_name: '模板1', template_english_name: 'template_one', annual_leave: 0, sick_leave: 0,
      office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,
      provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1,
      comment: 'test1')
    @second_welfare_template = create(
      :welfare_template, template_chinese_name: '模板2', template_english_name: 'template_two', annual_leave: 12, sick_leave: 6,
      office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,
      provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1,
      comment: 'test2')
    @first_welfare_template_id = @first_welfare_template.id
    @second_welfare_template_id = @second_welfare_template.id

    @first_salary_template = create(:salary_template, template_chinese_name: 'test1', template_english_name: 'template_one.', basic_salary: 100, bonus: 1.5, attendance_award: 300, house_bonus: 30, tea_bonus: 7, kill_bonus: 300, performance_bonus: 1000, charge_bonus: 700, commission_bonus: 200, receive_bonus: 500, exchange_rate_bonus: 100, guest_card_bonus: 100, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0, product_bonus: 0, comment: 'test1', belongs_to: {"13" => ["12"]})

    @second_salary_template = create(:salary_template, template_chinese_name: 'test2', template_english_name: 'template_two.', basic_salary: 200, bonus: 1, attendance_award: 0, house_bonus: 60, tea_bonus: 30, kill_bonus: 400, performance_bonus: 500, charge_bonus: 800, commission_bonus: 300, receive_bonus: 500, exchange_rate_bonus: 200, guest_card_bonus: 300, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0, product_bonus: 0, comment: 'test1', belongs_to: {"13" => ["11"]})
  end

  def test_salary_value_1
    profile_1 =  create_profile
    profile_1.send(
      :edit_field, {field: 'date_of_employment', new_value: Time.zone.now.beginning_of_month.strftime('%Y/%m/%d'), section_key: 'position_information'}.with_indifferent_access
    )
    User.where.not(id: profile_1.user_id).destroy_all
    create_float_month_salary_report
    user = profile_1.user
    create_social_security_fund_item(user)
    SocialSecurityFundItem. generate(user, Time.zone.now.beginning_of_month)


    AttendMonthlyReport.create(
      user_id: user.id, year_month: Time.zone.now.strftime('%Y%m').to_i, year: Time.zone.now.year, month: Time.zone.now.month,
      signcard_forget_to_punch_in_counts: 1, signcard_forget_to_punch_out_counts: 1,
      force_holiday_for_money_counts: 14, force_holiday_for_leave_counts: 15,
      public_holiday_for_money_counts: 16, absenteeism_counts: 17,
      unpaid_leave_counts: 18, immediate_leave_counts: 19,
      unpaid_marriage_leave_counts: 20, unpaid_compassionate_leave_counts: 21,
      pregnant_sick_leave_counts: 22, sick_leave_counts_not_link_off: 23,
      sick_leave_counts_link_off: 24, paid_maternity_leave_counts: 25,
      unpaid_maternity_leave_counts:26, work_injury_before_7_counts:27,
      work_injury_after_7_counts: 28, unpaid_but_maintain_position_counts: 29,
      late_mins_less_than_10: 30, late_mins_less_than_20: 31,
      late_mins_less_than_30: 32, late_mins_more_than_30: 33, weekdays_overtime_hours: 34, vehicle_department_overtime_mins: 34,
      general_holiday_overtime_hours: 35, typhoon_allowance_counts: 36



    )
    create_contribution_report(user)

    msr = MonthSalaryReport.create(year_month: Time.zone.now.beginning_of_month, salary_type: :on_duty)
    AccountingMonthSalaryReportJob.perform_now(msr)
    #1
    assert_equal user.empoid, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 1, salary_type: 'on_duty')).serializer_instance.value
    #2
    assert_equal user.as_json.reject{|key,value| key == 'created_at' || key == 'updated_at'}, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 2, salary_type: 'on_duty')).serializer_instance.value.reject{|key,value| key == 'created_at' || key == 'updated_at'}
    #3
    assert_equal Time.zone.now.beginning_of_year, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 3, salary_type: 'on_duty')).serializer_instance.value
    #4
    assert_equal Time.zone.now.beginning_of_month, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 4, salary_type: 'on_duty')).serializer_instance.value
    #5
    assert_equal Config.get_option_from_selects('company_name', user.company_name).first, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 5, salary_type: 'on_duty')).serializer_instance.value
    #6
    assert_equal user.location.as_json.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 6, salary_type: 'on_duty')).serializer_instance.value.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}
    #7
    assert_equal user.department.as_json.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 7, salary_type: 'on_duty')).serializer_instance.value.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}
    #8
    assert_equal user.position.as_json.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 8, salary_type: 'on_duty')).serializer_instance.value.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}
    #9
    assert_equal user.grade, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 9, salary_type: 'on_duty')).serializer_instance.value
    #10
    assert_equal 1, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 10, salary_type: 'on_duty')).serializer_instance.value
    #11
    assert_equal 1, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 11, salary_type: 'on_duty')).serializer_instance.value
    # # #12
    # assert_equal Time.zone.now.beginning_of_month, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 11, salary_type: 'on_duty')).serializer_instance.value
    # # #13
    # assert_equal Time.zone.now.beginning_of_year, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 3, salary_type: 'on_duty')).serializer_instance.value
    #14
    assert_equal 14, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 14, salary_type: 'on_duty')).serializer_instance.value
    #15
    assert_equal 15, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 15, salary_type: 'on_duty')).serializer_instance.value
    #16
    assert_equal 16, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 16, salary_type: 'on_duty')).serializer_instance.value
    #17
    assert_equal 17, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 17, salary_type: 'on_duty')).serializer_instance.value
    #18
    assert_equal 18, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 18, salary_type: 'on_duty')).serializer_instance.value
    #19
    assert_equal 19, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 19, salary_type: 'on_duty')).serializer_instance.value
    #20
    assert_equal 20, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 20, salary_type: 'on_duty')).serializer_instance.value
    #21
    assert_equal 21, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 21, salary_type: 'on_duty')).serializer_instance.value
    #22
    assert_equal 22, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 22, salary_type: 'on_duty')).serializer_instance.value
    #23
    assert_equal 23, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 23, salary_type: 'on_duty')).serializer_instance.value
    #24
    assert_equal 24, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 24, salary_type: 'on_duty')).serializer_instance.value
    #25
    assert_equal 26, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 25, salary_type: 'on_duty')).serializer_instance.value
    #26
    assert_equal 25, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 26, salary_type: 'on_duty')).serializer_instance.value
    #27
    assert_equal 27, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 27, salary_type: 'on_duty')).serializer_instance.value
    #28
    assert_equal 28, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 28, salary_type: 'on_duty')).serializer_instance.value
    #29
    assert_equal 29, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 29, salary_type: 'on_duty')).serializer_instance.value
    #30

    assert_equal 30, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 30, salary_type: 'on_duty')).serializer_instance.value
    #31
    assert_equal 31, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 31, salary_type: 'on_duty')).serializer_instance.value
    #32
    assert_equal 32, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 32, salary_type: 'on_duty')).serializer_instance.value
    #33
    assert_equal 33, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 33, salary_type: 'on_duty')).serializer_instance.value
    #34
    assert_equal 34+1, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 34, salary_type: 'on_duty')).serializer_instance.value
    #35
    assert_equal 35, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 35, salary_type: 'on_duty')).serializer_instance.value
    #36
    assert_equal 36, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 36, salary_type: 'on_duty')).serializer_instance.value
    #37
    assert_equal BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 37, salary_type: 'on_duty')).serializer_instance.value
    #38
    assert_equal BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 38, salary_type: 'on_duty')).serializer_instance.value
    #39
    assert_equal BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value
    #40
    assert_equal BigDecimal('11.5'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 40, salary_type: 'on_duty')).serializer_instance.value
    #41
    assert_equal BigDecimal('11.5'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 41, salary_type: 'on_duty')).serializer_instance.value
    #42
    assert_equal BigDecimal('11.5'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 42, salary_type: 'on_duty')).serializer_instance.value
    #43
    assert_equal BigDecimal('310'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 43, salary_type: 'on_duty')).serializer_instance.value
    #44
    assert_equal BigDecimal('310'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 44, salary_type: 'on_duty')).serializer_instance.value
    #45
    assert_equal BigDecimal('310'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 45, salary_type: 'on_duty')).serializer_instance.value

    #46
    assert_equal BigDecimal('40'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 46, salary_type: 'on_duty')).serializer_instance.value
    #47
    assert_equal BigDecimal('40'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 47, salary_type: 'on_duty')).serializer_instance.value
    #48
    assert_equal BigDecimal('40'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 48, salary_type: 'on_duty')).serializer_instance.value

    #49
    assert_equal BigDecimal('210'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 49, salary_type: 'on_duty')).serializer_instance.value
    #50
    assert_equal BigDecimal('210'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 50, salary_type: 'on_duty')).serializer_instance.value
    #51
    assert_equal BigDecimal('210'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 51, salary_type: 'on_duty')).serializer_instance.value

    #52
    assert_equal BigDecimal('17'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 52, salary_type: 'on_duty')).serializer_instance.value
    #53
    assert_equal BigDecimal('17'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 53, salary_type: 'on_duty')).serializer_instance.value
    #54
    assert_equal  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_tea_bonus, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 54, salary_type: 'on_duty')).serializer_instance.value
    #55
    assert_equal   BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 55, salary_type: 'on_duty')).serializer_instance.value

    #56
    assert_equal  BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_tea_bonus, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 56, salary_type: 'on_duty')).serializer_instance.value

    #57
    assert_equal  BigDecimal(210), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 57, salary_type: 'on_duty')).serializer_instance.value

    #58
    assert_equal  BigDecimal(210), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 58, salary_type: 'on_duty')).serializer_instance.value

    #59
    assert_equal  BigDecimal(210), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 59, salary_type: 'on_duty')).serializer_instance.value

    #60
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 60, salary_type: 'on_duty')).serializer_instance.value
    #61
    assert_equal  BigDecimal(100) * BigDecimal(210), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 61, salary_type: 'on_duty')).serializer_instance.value
    #62
    assert_equal   BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 62, salary_type: 'on_duty')).serializer_instance.value
    #63
    assert_equal  BigDecimal(100) * BigDecimal(210), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 63, salary_type: 'on_duty')).serializer_instance.value
    #64
    assert_equal  BigDecimal(100) * BigDecimal(210) * 2 , ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 64, salary_type: 'on_duty')).serializer_instance.value
    #65
    assert_equal  BigDecimal(310), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 65, salary_type: 'on_duty')).serializer_instance.value
    #66
    assert_equal  BigDecimal(310), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 66, salary_type: 'on_duty')).serializer_instance.value
    #67
    assert_equal  BigDecimal(310), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 67, salary_type: 'on_duty')).serializer_instance.value
    #68
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 68, salary_type: 'on_duty')).serializer_instance.value
    #69
    assert_equal  BigDecimal(310) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 69, salary_type: 'on_duty')).serializer_instance.value


    #70
    assert_equal  BigDecimal(1010), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 70, salary_type: 'on_duty')).serializer_instance.value
    #71
    assert_equal  BigDecimal(1010), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 71, salary_type: 'on_duty')).serializer_instance.value
    #72
    assert_equal  BigDecimal(1010), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 72, salary_type: 'on_duty')).serializer_instance.value
    #73
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 73, salary_type: 'on_duty')).serializer_instance.value
    #74
    assert_equal  BigDecimal(1010) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 74, salary_type: 'on_duty')).serializer_instance.value

    #75
    assert_equal  BigDecimal(710), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 75, salary_type: 'on_duty')).serializer_instance.value
    #76
    assert_equal  BigDecimal(710), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 76, salary_type: 'on_duty')).serializer_instance.value
    #77
    assert_equal  BigDecimal(710), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 77, salary_type: 'on_duty')).serializer_instance.value
    #78
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 78, salary_type: 'on_duty')).serializer_instance.value
    #79
    assert_equal  BigDecimal(710) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 79, salary_type: 'on_duty')).serializer_instance.value

    #80
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 80, salary_type: 'on_duty')).serializer_instance.value
    #81
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 81, salary_type: 'on_duty')).serializer_instance.value
    #82
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 82, salary_type: 'on_duty')).serializer_instance.value
    #83
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 83, salary_type: 'on_duty')).serializer_instance.value
    #84
    assert_equal  BigDecimal(110) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 84, salary_type: 'on_duty')).serializer_instance.value

    #85
    assert_equal  BigDecimal(510), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 85, salary_type: 'on_duty')).serializer_instance.value
    #86
    assert_equal  BigDecimal(510), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 86, salary_type: 'on_duty')).serializer_instance.value
    #87
    assert_equal  BigDecimal(510), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 87, salary_type: 'on_duty')).serializer_instance.value
    #88
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 88, salary_type: 'on_duty')).serializer_instance.value
    #89
    assert_equal  BigDecimal(510) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 89, salary_type: 'on_duty')).serializer_instance.value

    #90
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 90, salary_type: 'on_duty')).serializer_instance.value
    #91
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 91, salary_type: 'on_duty')).serializer_instance.value
    #92
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 92, salary_type: 'on_duty')).serializer_instance.value
    #93
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 93, salary_type: 'on_duty')).serializer_instance.value
    #94
    assert_equal  BigDecimal(110) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 94, salary_type: 'on_duty')).serializer_instance.value

    #95
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 95, salary_type: 'on_duty')).serializer_instance.value
    #96
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 96, salary_type: 'on_duty')).serializer_instance.value
    #97
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 97, salary_type: 'on_duty')).serializer_instance.value
    #98
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 98, salary_type: 'on_duty')).serializer_instance.value
    #99
    assert_equal  BigDecimal(10) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 99, salary_type: 'on_duty')).serializer_instance.value

    #100
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 100, salary_type: 'on_duty')).serializer_instance.value
    #101
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 101, salary_type: 'on_duty')).serializer_instance.value
    #102
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 102, salary_type: 'on_duty')).serializer_instance.value
    #103
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 103, salary_type: 'on_duty')).serializer_instance.value
    #104
    assert_equal  BigDecimal(300), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 104, salary_type: 'on_duty')).serializer_instance.value

    #105
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 105, salary_type: 'on_duty')).serializer_instance.value
    #106
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 106, salary_type: 'on_duty')).serializer_instance.value
    #107
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 107, salary_type: 'on_duty')).serializer_instance.value
    #108
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 108, salary_type: 'on_duty')).serializer_instance.value
    #109
    assert_equal  BigDecimal(300), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 109, salary_type: 'on_duty')).serializer_instance.value

    #110
    assert_equal  BigDecimal(300), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 110, salary_type: 'on_duty')).serializer_instance.value
    #111
    assert_equal  BigDecimal(300), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 111, salary_type: 'on_duty')).serializer_instance.value


    #112
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 112, salary_type: 'on_duty')).serializer_instance.value
    #113
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 113, salary_type: 'on_duty')).serializer_instance.value
    #114
    assert_equal  BigDecimal(10), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 114, salary_type: 'on_duty')).serializer_instance.value
    #115
    assert_equal  BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 115, salary_type: 'on_duty')).serializer_instance.value
    #116
    assert_equal  BigDecimal(10) * BigDecimal(100), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 116, salary_type: 'on_duty')).serializer_instance.value
    #117
    assert_equal  BigDecimal(110), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 117, salary_type: 'on_duty')).serializer_instance.value
    #118
    assert_equal  BigDecimal('11.5'), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 118, salary_type: 'on_duty')).serializer_instance.value
    #119
    assert_equal  BigDecimal(310), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 119, salary_type: 'on_duty')).serializer_instance.value

    #120
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 120, salary_type: 'on_duty')).serializer_instance.value
    #121
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 121, salary_type: 'on_duty')).serializer_instance.value
    #122
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 122, salary_type: 'on_duty')).serializer_instance.value
    #123
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 123, salary_type: 'on_duty')).serializer_instance.value
    #124
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 124, salary_type: 'on_duty')).serializer_instance.value
    #125
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 125, salary_type: 'on_duty')).serializer_instance.value
    #126
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 126, salary_type: 'on_duty')).serializer_instance.value
    #127
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 127, salary_type: 'on_duty')).serializer_instance.value
    #128
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 128, salary_type: 'on_duty')).serializer_instance.value
    #129
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 129, salary_type: 'on_duty')).serializer_instance.value
    #130
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 130, salary_type: 'on_duty')).serializer_instance.value
    #131
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 131, salary_type: 'on_duty')).serializer_instance.value
    #132
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 132, salary_type: 'on_duty')).serializer_instance.value
    #133
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 133, salary_type: 'on_duty')).serializer_instance.value
    #134
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 134, salary_type: 'on_duty')).serializer_instance.value
    #135
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 135, salary_type: 'on_duty')).serializer_instance.value
    #136
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 136, salary_type: 'on_duty')).serializer_instance.value
    #137
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 137, salary_type: 'on_duty')).serializer_instance.value
    #138
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 138, salary_type: 'on_duty')).serializer_instance.value
    #139
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 139, salary_type: 'on_duty')).serializer_instance.value
    #140
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 140, salary_type: 'on_duty')).serializer_instance.value
    #141
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 141, salary_type: 'on_duty')).serializer_instance.value
    #142
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 142, salary_type: 'on_duty')).serializer_instance.value
    #143
    assert_equal  Time.zone.now.beginning_of_month, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 143, salary_type: 'on_duty')).serializer_instance.value
    #144
    assert_equal  Time.zone.now.beginning_of_month, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 144, salary_type: 'on_duty')).serializer_instance.value
    #145
    assert_equal  Time.zone.now.end_of_month.beginning_of_day, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 145, salary_type: 'on_duty')).serializer_instance.value
    # #146
    # amount_for_tax = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 175, salary_type: 'on_duty')).serializer_instance.value -
    #   ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 187, salary_type: 'on_duty')).serializer_instance.value +
    #   ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 199, salary_type: 'on_duty')).serializer_instance.value -
    #   ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 215, salary_type: 'on_duty')).serializer_instance.value
    # housing_allowance = SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 48, salary_type: 'on_duty')).serializer_instance.value)
    # house_deduct =  housing_allowance > 500 ? (housing_allowance - BigDecimal(500)) : BigDecimal(0)
    # mop = (amount_for_tax - house_deduct)
    # re = SalaryCalculatorService.month_tax_mop(mop)
    # byebug
    # assert_equal  re, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 146, salary_type: 'on_duty')).serializer_instance.value

    #147
    assert_equal  SocialSecurityFundItem.first.employee_payment_mop, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 147, salary_type: 'on_duty')).serializer_instance.value
    #148
    assert_equal  user.profile.data['personal_information']['field_values']['id_number'], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 148, salary_type: 'on_duty')).serializer_instance.value
    #149
    assert_equal  user.profile.data['personal_information']['field_values']['tax_number'], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 149, salary_type: 'on_duty')).serializer_instance.value
    #150
    assert_equal  user.profile.data['personal_information']['field_values']['sss_number'], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 150, salary_type: 'on_duty')).serializer_instance.value
    #151
    assert_equal  ProfileService.position_of_govt_record(user), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 151, salary_type: 'on_duty')).serializer_instance.value
    #152
    assert_equal   user.position.as_json.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 152, salary_type: 'on_duty')).serializer_instance.value.select{|key| key == 'chinese_name' || key == 'english_name' || key == 'simple_chinese_name'}

    #153
    assert_equal  false, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 153, salary_type: 'on_duty')).serializer_instance.value
    #154
    assert_equal  false, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 154, salary_type: 'on_duty')).serializer_instance.value
    #155
    assert_equal   false, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 155, salary_type: 'on_duty')).serializer_instance.value



    #156
    assert_equal  ((Time.zone.now.end_of_month - user.career_records.first.career_begin) / 1.day).round, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 156, salary_type: 'on_duty')).serializer_instance.value
    #157
    assert_equal  0, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 157, salary_type: 'on_duty')).serializer_instance.value
    #158
    assert_equal         Config.get_single_option(:payment_method, user.profile.data['position_information']['field_values']['payment_method'])  , ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 158, salary_type: 'on_duty')).serializer_instance.value

    #159
    assert_equal  false, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 159, salary_type: 'on_duty')).serializer_instance.value
    #160
    assert_equal  false, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 160, salary_type: 'on_duty')).serializer_instance.value
    #161
    assert_equal   user.profile.data['personal_information']['field_values']['bank_of_china_account_mop'], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 161, salary_type: 'on_duty')).serializer_instance.value
    #162
    assert_equal  user.profile.data['personal_information']['field_values']['bank_of_china_account_hkd'], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 162, salary_type: 'on_duty')).serializer_instance.value
    #163
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 163, salary_type: 'on_duty')).serializer_instance.value
    #164
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 164, salary_type: 'on_duty')).serializer_instance.value
    #165
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 165, salary_type: 'on_duty')).serializer_instance.value




    # #166
    assert_equal (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 14, salary_type: 'on_duty')).serializer_instance.value *  SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value) / 30 ).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 166, salary_type: 'on_duty')).serializer_instance.value
    # #167
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 16, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 167, salary_type: 'on_duty')).serializer_instance.value
    # #168
    over_time_salary = if ActiveModelSerializers::SerializableResource.new(user.welfare_records.by_current_valid_record_for_welfare_info.first).serializer_instance.over_time_salary == 'one_point_two_times'
                         1.2
                       else
                         2
                       end
    weekday_overtime_hours = SalaryCalculatorService.find_or_create_by(34, user, msr, :on_duty)
    holiday_overtime_hours = SalaryCalculatorService.find_or_create_by(35, user, msr, :on_duty)

    re = (weekday_overtime_hours * 1.2 + holiday_overtime_hours * over_time_salary) /
      BigDecimal('30') /
      BigDecimal('8') *
      SalaryCalculatorService.hkd_to_mop(SalaryCalculatorService.find_or_create_by(39, user, msr, :on_duty))
    assert_equal  re.round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 168, salary_type: 'on_duty')).serializer_instance.value.round(2)
    #

    #169
    assert_equal  ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 26, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 169, salary_type: 'on_duty')).serializer_instance.value
    #170
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 170, salary_type: 'on_duty')).serializer_instance.value
    #171
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 171, salary_type: 'on_duty')).serializer_instance.value
    #172
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 172, salary_type: 'on_duty')).serializer_instance.value
    #173
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 173, salary_type: 'on_duty')).serializer_instance.value
    #174
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 174, salary_type: 'on_duty')).serializer_instance.value
    #175
    assert_equal   (
                     SalaryCalculatorService.math_add(SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)) +
                                                        SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 166, salary_type: 'on_duty')).serializer_instance.value) +
                                                                                           SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 167, salary_type: 'on_duty')).serializer_instance.value) +
                                                                                                                              SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 168, salary_type: 'on_duty')).serializer_instance.value) +
                                                                                                                                                                 SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 169, salary_type: 'on_duty')).serializer_instance.value )+
                                                                                                                                                                                                    SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 170, salary_type: 'on_duty')).serializer_instance.value )+
                                                                                                                                                                                                                                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 171, salary_type: 'on_duty')).serializer_instance.value )+
                                                                                                                                                                                                                                                                           SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 172, salary_type: 'on_duty')).serializer_instance.value )+
                                                                                                                                                                                                                                                                                                               SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 173, salary_type: 'on_duty')).serializer_instance.value )+
                                                                                                                                                                                                                                                                                                                                                  SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 174, salary_type: 'on_duty')).serializer_instance.value)
                   ), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 175, salary_type: 'on_duty')).serializer_instance.value
    #176
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 17, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 176, salary_type: 'on_duty')).serializer_instance.value
    #177
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 19, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 177, salary_type: 'on_duty')).serializer_instance.value
    #178
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 18, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 178, salary_type: 'on_duty')).serializer_instance.value
    #179
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 20, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 179, salary_type: 'on_duty')).serializer_instance.value
    #180
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 21, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 180, salary_type: 'on_duty')).serializer_instance.value
    #181
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 22, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 181, salary_type: 'on_duty')).serializer_instance.value
    #182
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 25, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 182, salary_type: 'on_duty')).serializer_instance.value
    #183
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 28, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 183, salary_type: 'on_duty')).serializer_instance.value
    #184
    assert_equal   (ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 29, salary_type: 'on_duty')).serializer_instance.value * SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, salary_type: 'on_duty')).serializer_instance.value)  / 30).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 184, salary_type: 'on_duty')).serializer_instance.value
    #185
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 185, salary_type: 'on_duty')).serializer_instance.value
    #186 : 補記錄
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 186, salary_type: 'on_duty')).serializer_instance.value


    #187
    assert_equal   (
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 176, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 177, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 178, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 179, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 180, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 181, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 182, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 183, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 184, salary_type: 'on_duty')).serializer_instance.value)+
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 185, salary_type: 'on_duty')).serializer_instance.value )+
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 186, salary_type: 'on_duty')).serializer_instance.value)
                   ), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 187, salary_type: 'on_duty')).serializer_instance.value

    #188
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 188, salary_type: 'on_duty')).serializer_instance.value
    #189
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 189, salary_type: 'on_duty')).serializer_instance.value

    #190
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 190, salary_type: 'on_duty')).serializer_instance.value

    #191
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 191, salary_type: 'on_duty')).serializer_instance.value
    #192
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 192, salary_type: 'on_duty')).serializer_instance.value
    #193
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 193, salary_type: 'on_duty')).serializer_instance.value

    #194
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 194, salary_type: 'on_duty')).serializer_instance.value
    #195
    assert_equal   (
                     SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 175, salary_type: 'on_duty')).serializer_instance.value) -
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 187, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 188, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 189, salary_type: 'on_duty')).serializer_instance.value )-
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 190, salary_type: 'on_duty')).serializer_instance.value )-
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 191, salary_type: 'on_duty')).serializer_instance.value )-
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 193, salary_type: 'on_duty')).serializer_instance.value) -
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 194, salary_type: 'on_duty')).serializer_instance.value)
                   ).round(1), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 195, salary_type: 'on_duty')).serializer_instance.value.round(1)
    #196
    assert_equal   nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 196, salary_type: 'on_duty')).serializer_instance.value
    #197 : 補記錄
    # {「漏打上班次數」＋「漏打下班次數」﹣1 }＊300；
    assert_equal   BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 197, salary_type: 'on_duty')).serializer_instance.value
    #198
    assert_equal   ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 36, salary_type: 'on_duty')).serializer_instance.value * 100, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 198, salary_type: 'on_duty')).serializer_instance.value
    #199
    assert_equal   (
                     SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 42, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 45, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 48, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 51, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 56, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 64, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 69, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 74, salary_type: 'on_duty')).serializer_instance.value )+
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 79, salary_type: 'on_duty')).serializer_instance.value)+
                       SalaryCalculatorService.mop_to_hkd(SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 84, salary_type: 'on_duty')).serializer_instance.value ))+
                        SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 89, salary_type: 'on_duty')).serializer_instance.value)+
                        SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 94, salary_type: 'on_duty')).serializer_instance.value )+
                        SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 99, salary_type: 'on_duty')).serializer_instance.value) +
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 104, salary_type: 'on_duty')).serializer_instance.value)+
                        SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 109, salary_type: 'on_duty')).serializer_instance.value )+
                        SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 110, salary_type: 'on_duty')).serializer_instance.value) +
                    SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 111, salary_type: 'on_duty')).serializer_instance.value)+
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 116, salary_type: 'on_duty')).serializer_instance.value )+
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 196, salary_type: 'on_duty')).serializer_instance.value) +
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 197, salary_type: 'on_duty')).serializer_instance.value)+
                      SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 198, salary_type: 'on_duty')).serializer_instance.value )
                   ).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 199, salary_type: 'on_duty')).serializer_instance.value

    department_float_salary = FloatSalaryMonthEntry.where(year_month: Time.zone.now.beginning_of_month).first.bonus_element_items.where(user_id: user.id).first.bonus_element_item_values.where(value_type: :departmental).map do |item|
      item.calc_amount
    end.sum
    personal_float_salary = FloatSalaryMonthEntry.where(year_month: Time.zone.now.beginning_of_month).first.bonus_element_items.where(user_id: user.id).first.bonus_element_item_values.where(value_type: :personal).map do |item|
      item.calc_amount
    end.sum
    #200
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 17, salary_type: 'on_duty')).serializer_instance.value
    bonus = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 42, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + department_float_salary) / 30 + days * 1500 * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty')).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 200, salary_type: 'on_duty')).serializer_instance.value
    #201
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 19, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + department_float_salary) / 30 + days * 1000 * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty')).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 201, salary_type: 'on_duty')).serializer_instance.value
    #202
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 18, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + department_float_salary) / 30 + days * 500 * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty')).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 202, salary_type: 'on_duty')).serializer_instance.value
    #203
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 20, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + department_float_salary) / 30 + days * 250 * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty')).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 203, salary_type: 'on_duty')).serializer_instance.value
    #204
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 21, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + department_float_salary) / 30 + days * 250 * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty')).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 204, salary_type: 'on_duty')).serializer_instance.value
    #205
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 25, salary_type: 'on_duty')).serializer_instance.value
    attendance = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 45, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + attendance * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty') + department_float_salary) / 30 ).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 205, salary_type: 'on_duty')).serializer_instance.value
    #206
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 22, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus + department_float_salary) / 30 ).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 206, salary_type: 'on_duty')).serializer_instance.value
    #207
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 28, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days *  department_float_salary / 30 + days * (bonus + attendance * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty')) / 30 / 3).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 207, salary_type: 'on_duty')).serializer_instance.value
    #208
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 29, salary_type: 'on_duty')).serializer_instance.value
    region_bonus = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 51, salary_type: 'on_duty')).serializer_instance.value
    house_bonus = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 48, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  (days * (bonus  + attendance * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty') + region_bonus + house_bonus + personal_float_salary + department_float_salary) / 30 ).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 208, salary_type: 'on_duty')).serializer_instance.value
    #209
    days = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 23, salary_type: 'on_duty')).serializer_instance.value
    days_2 = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 24, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  ((days * 250 + days_2 * 500) * SalaryCalculatorService.calculate_attendance_bonus_deduct_percentage(user, msr, 'on_duty') ).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 209, salary_type: 'on_duty')).serializer_instance.value
    #210
    times_1 = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 30, salary_type: 'on_duty')).serializer_instance.value
    times_1 = times_1 - 3  < 0 ? 0 : times_1 - 3
    times_2 = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 31, salary_type: 'on_duty')).serializer_instance.value

    times_3 = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 32, salary_type: 'on_duty')).serializer_instance.value
    times_4 = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 33, salary_type: 'on_duty')).serializer_instance.value
    assert_equal  SalaryCalculatorService.calculate_210_211_deduct(user, msr, 'on_duty')[:deduct_210], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 210, salary_type: 'on_duty')).serializer_instance.value
    #211
    times = ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 10, salary_type: 'on_duty')).serializer_instance.value + ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 11, salary_type: 'on_duty')).serializer_instance.value
    times = times - 1 < 0 ? 0 : times - 1
    assert_equal  SalaryCalculatorService.calculate_210_211_deduct(user, msr, 'on_duty')[:deduct_211], ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 211, salary_type: 'on_duty')).serializer_instance.value
    # #212
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 212, salary_type: 'on_duty')).serializer_instance.value
    #213
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 213, salary_type: 'on_duty')).serializer_instance.value
    #214
    assert_equal  BigDecimal(0), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 214, salary_type: 'on_duty')).serializer_instance.value
    #215
    assert_equal   (
                     SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 200, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 201, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 202, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 203, salary_type: 'on_duty')).serializer_instance.value ) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 204, salary_type: 'on_duty')).serializer_instance.value ) +
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 205, salary_type: 'on_duty')).serializer_instance.value ) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 206, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 207, salary_type: 'on_duty')).serializer_instance.value ) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 208, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 209, salary_type: 'on_duty')).serializer_instance.value ) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 210, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 211, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 212, salary_type: 'on_duty')).serializer_instance.value ) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 213, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add( ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 214, salary_type: 'on_duty')).serializer_instance.value)
                   ).round, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 215, salary_type: 'on_duty')).serializer_instance.value.round
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 216, salary_type: 'on_duty')).serializer_instance.value
    #217
    assert_equal  nil, ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 217, salary_type: 'on_duty')).serializer_instance.value
    #218
    assert_equal   tag1  = (
                     SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 199, salary_type: 'on_duty')).serializer_instance.value) -
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 215, salary_type: 'on_duty')).serializer_instance.value) +
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 216, salary_type: 'on_duty')).serializer_instance.value) -
                       SalaryCalculatorService.math_add(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 217, salary_type: 'on_duty')).serializer_instance.value )
                   ), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 218, salary_type: 'on_duty')).serializer_instance.value


    #测试更新后的值
    SalaryValue.find_by(user_id: user.id, salary_column_id: 217).update_value('30')
    assert_equal (BigDecimal(-30) + tag1).round(2), ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 218, salary_type: 'on_duty')).serializer_instance.value.round(2)

  end

  private

  def create_contribution_report(user)
    ContributionReportItem.generate(user, Time.zone.now.beginning_of_month, nil)
    assert_equal ContributionReportItem.first.relevant_income, BigDecimal(0)
  end

  def create_social_security_fund_item(user)
    SocialSecurityFundItem.generate(user, Time.zone.now.beginning_of_month)
  end

  def create_float_month_salary_report
    BonusElement.load_predefined
    FloatSalaryMonthEntry.create_by_year_month(Time.zone.now.beginning_of_month)
    fsm = FloatSalaryMonthEntry.first
    assert_equal fsm.status, 'not_approved'
    assert_equal fsm.location_statuses.where(location_id: 100).first.employees_on_duty, 1
    assert_equal fsm.location_department_statuses.where(location_id: 100, department_id: 13).first.employees_on_duty, 1
    #1
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 1}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_tea_bonus
    #2
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 2}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_kill_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 3}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_performance_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 4}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_charge_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 5}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_commission_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 6}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_receive_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 7}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_exchange_rate_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 8}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_guest_card_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 10}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_new_year_bonus
    assert_equal fsm.bonus_element_month_shares.where(location_id: 100, department_id: 13).joins(:bonus_element).where(bonus_elements: {order: 11}).first.shares,  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_project_bonus
    #
    month_amounts = BonusElementMonthAmount.all
    updates = month_amounts.map { |s| { id: s.id, amount: '100' } }
    patch batch_update_bonus_element_month_amounts_url, params: { bonus_element_month_amount: { updates: updates } }
    assert_response :success
    assert_equal BonusElementMonthAmount.all.where(amount: 100).count , 12
    post bonus_element_items_float_salary_month_entry_url(FloatSalaryMonthEntry.last)
    assert_response :success
    fsm = FloatSalaryMonthEntry.first
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 1}).first.per_share, BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 2}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 3}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 4}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 5}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 6}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 7}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 8}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 9}).first.per_share,nil
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 10}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 11}).first.per_share,BigDecimal(100)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 12}).first.per_share,nil
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 13}).first.per_share,nil
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 14}).first.per_share,nil
    BonusElementItemValue.all.each do  |item|
      if item.value_type == 'personal'
        item.update(amount: 300)
      else
        item.update(amount: item.shares * item.per_share)
      end
    end
    fsm = FloatSalaryMonthEntry.first
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 1}).first.amount, BigDecimal(100) *  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_tea_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 2}).first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_kill_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 3}).first.amount,BigDecimal(100) *  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_performance_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 4}).first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_charge_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 5}).where(subtype: 'business_development').first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_commission_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 5}).where(subtype: 'operation').first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_commission_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 6}).first.amount,BigDecimal(100) *  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_receive_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 7}).first.amount,BigDecimal(100) *  ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_exchange_rate_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 8}).first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_guest_card_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 9}).first.amount,BigDecimal(300)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 10}).first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_project_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 11}).first.amount,BigDecimal(100) * ActiveModelSerializers::SerializableResource.new(SalaryRecord.first).serializer_instance.final_project_bonus
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 12}).first.amount,BigDecimal(300)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 13}).first.amount,BigDecimal(300)
    assert_equal fsm.bonus_element_items.first.bonus_element_item_values.joins(:bonus_element).where(bonus_elements: {order: 14}).first.amount,BigDecimal(300)

    FloatSalaryMonthEntry.first.update(status: 'approved')
  end


  def create_profile
    SalaryTemplate.destroy_all
    salary_template = create(:salary_template, template_chinese_name: '模板1.', template_english_name: 'template_one.',
                             basic_salary: 100, bonus: 1.5, attendance_award: 300, house_bonus: 30, tea_bonus: 7, kill_bonus: 300,
                             performance_bonus: 1000, charge_bonus: 700, commission_bonus: 200, receive_bonus: 500,
                             exchange_rate_bonus: 100, guest_card_bonus: 100, respect_bonus: 100, new_year_bonus: 0, project_bonus: 0,
                             product_bonus: 0, comment: 'test1', region_bonus: 200)
    welfare_template = create(:welfare_template, template_chinese_name: '模板1.', template_english_name: 'template_one.', annual_leave: 0, sick_leave: 0, office_holiday: 1.5, holiday_type: 'none_holiday', probation: 30, notice_period: 7, double_pay: true, reduce_salary_for_sick: true,  provide_uniform: false, salary_composition: 'fixed', over_time_salary: 1, comment: 'test1', belongs_to: {"1" => ["1"]})

    create(:medical_template, id: 1, chinese_name: '第一級醫療保險計劃', english_name: 'The first level medical insurance plan', simple_chinese_name: '第一级医疗保险计划', insurance_type: 'medical_template.enum_insurance_type.suncity_insurance', balance_date: Date.today+1.month)
    ProfilesController.any_instance.stubs(:get_medical_template_up_to_grade).with(anything).returns(1)
    get '/profiles/template', params: {region: 'macau'}
    assert_response :ok
    assert_equal json_res['data'][1]['fields'].select{|hash| hash['key'] == 'resigned_date'}.length, 0
    template = json_res['data']
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    filled_template.find { |s| s['key'] == 'position_information' }['field_values']['position'] = 12
    filled_template.find { |s| s['key'] == 'position_information' }['field_values']['location'] = 100
    filled_template.find { |s| s['key'] == 'position_information' }['field_values']['department'] = 13
    # post data to create user Profile
    assert_difference(['Profile.count', 'User.count', 'ProfileAttachment.count'], 1) do
      post '/profiles', params: {
        sections: filled_template,
        region: 'macau',
        attachments: [{
                        file_name: 'test file name',
                        attachment_id: create(:attachment).id
                      }],
        welfare_record:{
          welfare_begin: Time.zone.now - 1.month,
          welfare_template_id: welfare_template.id,
          change_reason: 'entry',
        },
        salary_record: {
          salary_begin: Time.zone.now - 1.month,
          salary_template_id: salary_template.id,
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
        },
        wrwt: {
          provide_airfare: true,
          provide_accommodation: true,
          airfare_type: 'count',
          airfare_count: 1,
        },
        love_fund: {
          valid_date: Time.zone.now + 1.day,
          to_status: 'participated_in_the_future'
        },
        medical_insurance_participator: {
          valid_date: Time.zone.now  + 1.day,
          to_status: 'participated_in_the_future'
        },
        shift_status: {
          is_shift: true,
        },
        punch_card_state: {
          is_need: true,
          creator_id: current_user.id,
        }
      }, as: :json
      assert_response :ok

      assert json_res['data'].key?('id')
      assert_equal SalaryRecord.first.status, 'being_valid'
      assert_equal WelfareRecord.first.status, 'being_valid'
      assert_equal SalaryRecord.first.salary_template_id, salary_template.id
      assert_equal WelfareRecord.first.welfare_template_id, welfare_template.id
      assert_equal Wrwt.first.provide_airfare, true
      assert_equal LoveFund.first.participate, 'not_participated'
      assert_equal MedicalInsuranceParticipator.first.participate, 'not_participated'
      assert_equal CareerRecord.first.status, 'being_valid'

      assert_response :ok
      Profile.find(json_res['data']['id'])
    end

  end

end