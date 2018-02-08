# coding: utf-8
require 'test_helper'

class TransferPositionApplyByEmployeesControllerTest < ActionDispatch::IntegrationTest
  setup do
    ApplicationController.any_instance.stubs(:authorize).returns(true)
  end

  test "post create transfer postion apply by employee & show detail" do

    location = create(:location, id: 90,chinese_name: '银河')
    department = create(:department, id: 9,chinese_name: '行政及人力資源部')
    position = create(:position, id: 39, chinese_name: '網絡及系統副總監')


    user = create_test_user
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
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

    TransferPositionApplyByEmployeesController.any_instance.stubs(:current_user).returns(user)
    params = {
      user_id: user.id,

      region: 'macau',
      apply_date: '2017/01/10',
      comment: 'test comment',
      apply_location_id: location.id,
      apply_department_id: department.id,
      apply_position_id: position.id,
      apply_reason: 'apply reason',
      is_recommended_by_department: true,
      reason: 'recommended reason',
      is_continued: true,
      interview_date_by_department: '2017/03/21',
      interview_time_by_department: '2017/03/21 12:00:00',
      interview_location_by_department: 'interview location',
      interview_result_by_department: true,
      interview_comment_by_department: 'interview comment by department',
      interview_date_by_header: '2017/03/22',
      interview_time_by_header: '2017/03/22 12:00:00',
      interview_location_by_header: 'interview location',
      interview_result_by_header: false,
      interview_comment_by_header: 'interview comment by header',
      is_transfer: true,
      transfer_date: '2017/03/15',
      transfer_location_id: location.id,
      transfer_department_id: department.id,
      transfer_position_id: position.id,

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


      new_welfare_record: {
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
      },

      training_courses: [
        {
          user_id: user.id,
          chinese_name: '課程 1',
          english_name: 'course 1',
          simple_chinese_name: '课程 1',
          explanation: 'test explanation 1',
        },
        {
          user_id: user.id,
          chinese_name: '課程 2',
          english_name: 'course 2',
          simple_chinese_name: '课程 2',
          explanation: 'test explanation 2',
        },
        {
          user_id: user.id,
          chinese_name: '課程 3',
          explanation: 'test explanation 3',
        }
      ],
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
    assert_difference(['TransferPositionApplyByEmployee.count'], 1) do
      assert_difference(['JobTransfer.count'], 1) do
        assert_difference(['ApprovalItem.count'], 3) do
          assert_difference(['TrainingCourse.count'], 3) do
            assert_difference(['AttendAttachment.count'], 3) do
              assert_difference(['CareerRecord.count'], 1) do
                assert_difference(['SalaryRecord.count'], 1) do
                  assert_difference(['WelfareRecord.count'], 1) do
                    post '/job_transfers/transfer_position_apply_by_employees', params: params, as: :json
                    assert_response :ok
                  end
                end
              end
            end
          end
        end
      end
    end

    tfa = TransferPositionApplyByEmployee.first
    get "/job_transfers/transfer_position_apply_by_employees/#{tfa.id}", as: :json
    assert_response :ok

    assert_equal 3, json_res['data']['approval_items'].count
    assert_equal 3, json_res['data']['training_courses'].count
    assert_equal 3, json_res['data']['attend_attachments'].count

    get "/job_transfers?region=macau", as: :json
    assert_response :ok
    assert_equal 1, json_res['meta']['total_count']
    assert_equal 1, json_res['data'].count
    assert_equal "transfer_position_apply_by_employee", json_res['data'].first['transfer_type']
  end
end
