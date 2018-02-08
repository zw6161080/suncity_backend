# coding: utf-8
require 'test_helper'

class PassEntryTrialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ApplicationController.any_instance.stubs(:authorize).returns(true)
  end

  test "post create pass_entry_trial & show" do

    position = create(:position)
    location = create(:location)
    department = create(:department)
    user = create_test_user
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: location.id,
      position_id: position.id,
      department_id: department.id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: user.id
    }
    test_ca = CareerRecord.create(params)
    params = {
      welfare_begin: Time.zone.now,
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
      user_id: test_id = user.id,
    }
    @welfare_record = WelfareRecord.create(params)
    user.grade = 1
    user.save

    location = create(:location, id: 90,chinese_name: '银河')
    department = create(:department, id: 9,chinese_name: '行政及人力資源部')
    position = create(:position, id: 39, chinese_name: '網絡及系統副總監')

    aqt_items = [*9..28].map { |i| { order_no: i, score: 3, explain: "test #{i}" } }
    PassEntryTrialsController.any_instance.stubs(:current_user).returns(user)

    params = {
      user_id: user.id,
      creator_id: user.id,
      region: 'macau',
      apply_date: '2017/01/10',
      employee_advantage: 'advantage',
      employee_need_to_improve: 'improvement',
      employee_opinion: 'opinion',
      result: true,
      trial_expiration_date: '2017/03/01',
      dismissal: false,
      last_working_date: nil,
      comment: 'test comment',
      questionnaire_items: aqt_items,
      salary_calculation: 'do_not_adjust_the_salary',

      new_career_record: {
        career_begin: '2017/01/01',
        career_end: '2017/02/02',
        trial_period_expiration_date: '2017/02/01',
        salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited',
        location_id: location.id,
        department_id: department.id,
        position_id: position.id,
        grade: '2',
        employment_status: 'informal_employees',
        division_of_job: 'front_office',
        deployment_instructions: '调配说明',
        comment: 'comment',
      },

      new_salary_record: {
        salary_begin: "2017/01/23",
        salary_end: "2017/02/23",
        basic_salary: 300,
        bonus: 300,
        attendance_award: 300,
        house_bonus: 300,
        tea_bonus: 300,
        kill_bonus: 300,
        performance_bonus: 300,
        charge_bonus: 300,
        commission_bonus: 300,
        receive_bonus: 300,
        exchange_rate_bonus: 300,
        guest_card_bonus: 300,
        respect_bonus: 200,
        new_year_bonus: 200,
        project_bonus: 200,
        product_bonus: 200,
        region_bonus: 100,
      },
      approval_items: [
        {
          user_id: user.id,
          date: '2017/01/10',
          comment: 'test comment',
        },
        {
          user_id: user.id,
          date: '2017/01/10',
          comment: 'test comment',
        },
        {
          user_id: user.id,
          date: '2017/01/10',
          comment: 'test comment',
        }
      ],
      attend_attachments: [
        {
          file_name: '1.jpg',
          comment: 'test comment 1',
          attachment_id: 1
        },
        {
          file_name: '2.jpg',
          comment: 'test comment 2',
          attachment_id: 2
        },
        {
          file_name: '3.jpg',
          comment: 'test comment 3',
          attachment_id: 3
        }
      ]
    }

    assert_difference(['PassEntryTrial.count'], 1) do
      assert_difference(['JobTransfer.count'], 1) do
        assert_difference(['ApprovalItem.count'], 3) do
          assert_difference(['CareerRecord.count'], 1) do
            assert_difference(['AttendAttachment.count'], 3) do
              post '/job_transfers/pass_entry_trials/can_create', params: params, as: :json
              assert_response :ok

              post '/job_transfers/pass_entry_trials', params: params, as: :json
              pet = PassEntryTrial.first
              assert_response :ok
              assert_equal pet.assessment_questionnaire.items.count, 20
            end
          end
        end
      end
    end

    pet = PassEntryTrial.first
    get "/job_transfers/pass_entry_trials/#{pet.id}", as: :json
    assert_response :ok


    assert_equal 3, json_res['data']['approval_items'].count
    assert_equal 3, json_res['data']['attend_attachments'].count
    assert_equal 20, json_res['data']['questionnaire_items'].count
    assert_equal 9, json_res['data']['questionnaire_items'].first['order_no']
    assert_equal 28, json_res['data']['questionnaire_items'].last['order_no']
  end
end
