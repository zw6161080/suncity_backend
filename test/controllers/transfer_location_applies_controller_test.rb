# coding: utf-8
require 'test_helper'

class TransferLocationAppliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    ApplicationController.any_instance.stubs(:authorize).returns(true)
  end


  test "post create transfer location apply & show detail" do
    # user = create(:user)
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
    TransferLocationAppliesController.any_instance.stubs(:current_user).returns(user)
    location = create(:location, id: 90,chinese_name: '银河')

    params = {
      region: 'macau',
      creator_id: user.id,
      apply_date: '2017/01/10',
      comment: 'test comment',
      transfer_location_items: [
        {
          region: 'macau',
          user_id: user.id,
          transfer_date: '2017/01/10',
          transfer_location_id: location.id,
          salary_calculation: 'do_not_adjust_the_salary',
          comment: 'test comment 1',
        },
        {
          region: 'macau',
          user_id: user.id,
          transfer_date: '2017/02/10',
          transfer_location_id: location.id,
          salary_calculation: 'do_not_adjust_the_salary',
          comment: 'test comment 2',
        },
        {
          region: 'macau',
          user_id: user.id,
          transfer_date: '2017/03/10',
          transfer_location_id: location.id,
          salary_calculation: 'do_not_adjust_the_salary',
          comment: 'test comment 3',
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

    assert_difference(['TransferLocationApply.count'], 1) do
      assert_difference(['JobTransfer.count'], 3) do
        assert_difference(['ApprovalItem.count'], 3) do
          assert_difference(['TransferLocationItem.count'], 3) do
            assert_difference(['AttendAttachment.count'], 3) do
              assert_difference(['MuseumRecord.count'], 3) do
                post '/job_transfers/transfer_location_applies', params: params, as: :json
                assert_response :ok
              end
            end
          end
        end
      end
    end

    tla = TransferLocationApply.first
    get "/job_transfers/transfer_location_applies/#{tla.id}", as: :json
    assert_response :ok
    assert_equal 3, json_res['data']['approval_items'].count
    assert_equal 3, json_res['data']['attend_attachments'].count
    assert_equal 3, json_res['data']['transfer_location_items'].count

  end
end
