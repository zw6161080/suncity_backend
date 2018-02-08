require "test_helper"

class GrantTypeDetailTest < ActiveSupport::TestCase
  def grant_type_detail
    @grant_type_detail ||= GrantTypeDetail.new
  end

  def test_create
    test_user =  create_test_user
    params = {
      user_id: test_user.id,
      add_basic_salary: true,
      basic_salary_time: 1,
      add_bonus: true,
      bonus_time: 1,
      add_attendance_bonus: true,
      attendance_bonus_time: 1,
      add_fixed_award: true,
      fixed_award_mop: 2000,
      annual_award_report_id: 1
    }
    gtd = GrantTypeDetail.create_with_params(params)
    assert gtd.valid?

  end
  private
  def test_valid
    assert grant_type_detail.valid?
  end
end
