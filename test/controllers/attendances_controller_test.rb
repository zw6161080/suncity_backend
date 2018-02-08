# coding: utf-8
require 'test_helper'

class AttendancesControllerTest < ActionDispatch::IntegrationTest

  test "获取考勤表列表接口" do
    10.times { create(:attendance) }

    get '/attendances', params: { region: 'macau' }

    assert_response :ok
    assert_equal 10, json_res['data'].length
    assert json_res['data'].first.key?('location')
    assert json_res['data'].first.key?('department')
    assert json_res['data'].first.key?('department_employees_count')
  end

  test "考勤表接口按 date 筛选" do
    10.times { create(:attendance) }

    attendance = Attendance.first
    year = attendance['year']
    month = attendance['month']

    get '/attendances', params: {
          region: 'macau',
          year: year,
          month: month
        }
    assert_response :ok
    assert_equal Attendance.where(year: year).where(month: month).count, json_res['data'].length
  end

  test "考勤表接口按 location 筛选" do
    10.times { create(:attendance) }

    location = Location.first

    get '/attendances', params: {
          region: 'macau',
          location_id: location.id
        }
    assert_response :ok
    assert_equal Attendance.where(location_id: location.id).count, json_res['data'].length
  end

  test "考勤表接口按 department 筛选" do
    10.times { create(:attendance) }

    department = Department.first

    get '/attendances', params: {
          region: 'macau',
          department_id: department.id
    }
    assert_response :ok
    assert_equal Attendance.where(department_id: department.id).count, json_res['data'].length
  end

  test "考勤表接口按 department, location 筛选" do
    10.times { create(:attendance) }

    location = Location.first
    department = Department.first

    get '/attendances', params: {
          region: 'macau',
          location_id: location.id,
          department_id: department.id
        }
    assert_response :ok
    assert_equal Attendance.where(location_id: location.id).where(department_id: department.id).count, json_res['data'].length
  end

  test "考勤表接口按 department, location, date 筛选" do
    10.times { create(:attendance) }

    location = Location.first
    department = Department.first

    attendance = Attendance.first
    year = attendance['year']
    month = attendance['month']

    get '/attendances', params: {
          region: 'macau',
          year: year,
          month: month,
          location_id: location.id,
          department_id: department.id
        }
    assert_response :ok
    assert_equal Attendance
                   .where(year: year)
                   .where(month: month)
                   .where(location_id: location.id)
                   .where(department_id: department.id)
                   .count,
                 json_res['data'].length
  end

  test "获取排班表详情接口" do
    attendance= create(:attendance)

    get "/attendances/#{attendance.id}"

    assert_response :ok
    assert json_res.key?('state')
  end
end
