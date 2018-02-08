require "test_helper"

class AnnualAwardReportTest < ActiveSupport::TestCase
  def test_create
    params = {
      year_month: Time.zone.parse('2017/01/01'),
      annual_attendance_award_hkd: '200',
      annual_bonus_grant_type: 'all',
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
          key: 'all',
          add_basic_salary: true,
          basic_salary_time: 1,
          add_bonus: true,
          bonus_time: 1,
          add_attendance_bonus: true,
          attendance_bonus_time: 1
        }
      ]
    }


    aar = AnnualAwardReport.create_with_params(params)
    assert aar.valid?
    aa1r = AnnualAwardReport.create_with_params(params)
    assert_not aa1r.valid?

    params1 = {
      year_month: Time.zone.parse('2016/01/01'),
      annual_attendance_award_hkd: '200',
      annual_bonus_grant_type: 'all',
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
          key: 'all',
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
    aar2 = AnnualAwardReport.create_with_params(params1)

    assert aar2.valid?
    params1 = {
      year_month: Time.zone.parse('2013/01/01'),
      annual_attendance_award_hkd: '200',
      annual_bonus_grant_type: 'division_of_job',
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
          key: 'front_office',
          add_basic_salary: true,
          basic_salary_time: 1,
          add_bonus: true,
          bonus_time: 1,
          add_attendance_bonus: true,
          attendance_bonus_time: 1,
          add_fixed_award: true
        },
        {
          key: 'back_office',
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
    aar2 = AnnualAwardReport.create_with_params(params1)
    assert aar2.valid?
    params1 = {
      year_month: Time.zone.parse('2014/01/01'),
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
    aar2 = AnnualAwardReport.create_with_params(params1)
    assert aar2.valid?
  end


  def annual_award_report
    @annual_award_report ||= AnnualAwardReport.new
  end
  private
  def test_valid
    assert annual_award_report.valid?
  end
end
