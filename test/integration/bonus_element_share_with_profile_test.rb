require 'test_helper'

class BonusElementShareWithProfileTest < ActionDispatch::IntegrationTest
  setup do
    OccupationTaxSetting.load_predefined
    User.destroy_all
    SalaryColumn.generate


    current_user = create(:user)
    single_department = create(:department, id: 13)
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

  def test_bonus_share
    User.destroy_all
    profile = create_profile
    user = profile.user
    BonusElement.load_predefined
    float_salary_month_entry = FloatSalaryMonthEntry.create_by_year_month(Time.zone.now.strftime('%Y/%m'))
    assert_equal BonusElementMonthShare.where(location_id: user.location_id, department_id: user.department_id)
                   .joins(:bonus_element).where(bonus_elements: {order: 1}).first.shares, BigDecimal(17)
  end

  private
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
    department = create(:department, id: 2, chinese_name: '市場傳播部')
    create(:position, id: 1, chinese_name: '網絡及系統副總監')
    location = create(:location, id: 1 )
    location.departments << department
    get '/profiles/template', params: {region: 'macau'}
    assert_response :ok
    assert_equal json_res['data'][1]['fields'].select{|hash| hash['key'] == 'resigned_date'}.length, 0
    template = json_res['data']
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    filled_template.find { |s| s['key'] == 'position_information' }['field_values']['location'] = 1
    filled_template.find { |s| s['key'] == 'position_information' }['field_values']['department'] = 2

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
          salary_end: Time.zone.now.end_of_month,
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
