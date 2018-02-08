require 'test_helper'

class AnnualAwardReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :annual_award, :macau)
  end
  def annual_award_report
    @annual_award_report ||= annual_award_reports :one
  end

  def test_index
    AnnualAwardReportsController.any_instance.stubs(:current_user).returns(create_test_user)
    get annual_award_reports_url
    assert_response 403
    test_user = create_test_user
    test_user.add_role(@admin_role)

    AnnualAwardReportsController.any_instance.stubs(:current_user).returns(test_user)
    get annual_award_reports_url
    assert_response :success
  end

  def test_create
    SalaryColumn.generate
    User.destroy_all
    test_user = create_test_user
    test_user.update(department_id: 1)

    User.stubs(:where).with(anything).returns(User.all)
    create(:department, id: 1)
    params1 = {
      year_month: '2014/01/01',
      annual_attendance_award_hkd: '200',
      annual_bonus_grant_type: 'departments',
      absence_deducting: '100',
      notice_deducting: '100',
      late_5_times_deducting: '100',
      sign_card_deducting: '100',
      one_letter_of_warning_deducting: '100',
      two_letters_of_warning_deducting: '100',
      each_piece_of_awarding_deducting: '100',
      method_of_settling_accounts: 'wage',
      award_date: '2017/06',
      grant_type_rule: [
        {
          key: 1,
          add_basic_salary: true,
          basic_salary_time: 1,
          add_bonus: true,
          bonus_time: 1,
          add_attendance_bonus: true,
          attendance_bonus_time: 1,
          add_fixed_award: true
        }
      ]
    }
    User.all.each do |test_user|
      params = {
        career_begin: Time.zone.now.beginning_of_day,
        user_id: test_user.id,
        deployment_type: 'entry',
        salary_calculation: 'do_not_adjust_the_salary',
        company_name: 'suncity_gaming_promotion_company_limited',
        location_id: test_user.location_id,
        position_id: test_user.position_id,
        department_id: test_user.department_id,
        grade: 1,
        division_of_job: 'front_office',
        employment_status: 'informal_employees',
        inputer_id: test_user.id
      }
      test_ca = CareerRecord.create(params)
    end
    assert_difference('AnnualAwardReport.count') do
      AnnualAwardReportsController.any_instance.stubs(:current_user).returns(test_user)
      post annual_award_reports_url, params: params1
      assert_response 403
      test_user.add_role(@admin_role)
      AnnualAwardReportsController.any_instance.stubs(:current_user).returns(test_user)
      post annual_award_reports_url, params: params1
      assert_response 201
    end
    assert_equal AnnualAwardReport.first.year_month.to_date.to_s, '2014-01-01'
    assert_equal AnnualAwardReport.first.grant_type_rule.first['key'], '1'
    assert_response 201
    assert_equal GrantTypeDetail.first.user_id, test_user.id
    assert_equal AnnualAwardReport.first.status, 'calculating'
    AccountAnnualAwardItemsJob.perform_now(AnnualAwardReport.first)
    assert AnnualAwardReportItem.count > 0
    patch grant_annual_award_report_url(AnnualAwardReport.first.id)
    assert_response :ok
    assert_equal AnnualAwardReport.first.status, 'has_granted'
  end

  def test_annual_bonus_grant_type_options
    create(:department)
    get grant_type_options_annual_award_reports_url
    assert_equal json_res['departments'].first['id'], Department.first.id
  end
end
