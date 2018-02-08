# coding: utf-8
require "test_helper"

class AttendAnnualReportTest < ActiveSupport::TestCase
  setup do
    User.all.each { |u| u.destroy }
    profile = create_profile
    @user = profile.user
    location = create(:location, chinese_name: '银河')
    department = create(:department, chinese_name: '行政及人力資源部')
    position = create(:position, chinese_name: '網絡及系統副總監')
    @user.location_id = location.id
    @user.department_id = department.id
    @user.position_id = position.id
    @user.save
  end

  def attend_annual_report
    @attend_annual_report ||= AttendAnnualReport.new
  end

  def test_valid
    assert attend_annual_report.valid?
  end

  def test_general_report
    byebug
    AttendAnnualReport.generate_reports(2017)
    byebug
  end
end
