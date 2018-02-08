# coding: utf-8
require 'test_helper'

class LoveFundsControllerTest < ActionDispatch::IntegrationTest
  setup do

    @profile1 = create_profile
    @profile2 = create_profile
    @test_profile = create_profile
    @current_user = @test_profile.user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :LoveFund, :macau)
    @current_user.add_role(@admin_role)
    @another_user = create_test_user
    LoveFundsController.any_instance.stubs(:current_user).returns(@current_user)

    create(:department, id: User.find(@profile1.user_id).department_id, chinese_name: '行政及人力資源部')
    create(:position,   id: User.find(@profile1.user_id).position_id,   chinese_name: '網絡及系統副總監')
    LoveFund.create(user_id: @profile1.user_id, profile_id: @profile1.id, participate: 'love_fund.enum_participate.participated', participate_date: Time.zone.parse('2017/01/01'), cancel_date: Time.zone.parse('2017/01/01')+3.months, monthly_deduction: 20, to_status: 'not_participated_in_the_future', operator_id: @test_profile.id)
    LoveFund.create(user_id: @profile2.user_id, profile_id: @profile2.id, participate: 'love_fund.enum_participate.participated', participate_date: Time.zone.parse('2017/01/03'), cancel_date: Time.zone.parse('2017/01/03')+3.months, monthly_deduction: 20, operator_id: @test_profile.id )
    @love_fund = LoveFund.all[1]
  end

  test 'should create' do
    LoveFundsController.any_instance.stubs(:current_user).returns(@another_user)
    patch "/profiles/#{@profile1.id}/love_fund", params: {
      to_status: 'participated_in_the_future',
      valid_date: Time.zone.now
    }
    assert_response 403
    LoveFundsController.any_instance.stubs(:current_user).returns(@current_user)
    patch "/profiles/#{@profile1.id}/love_fund", params: {
      to_status: 'participated_in_the_future',
      valid_date: Time.zone.now
    }
    assert_response :ok
    assert_equal LoveFund.find_by_profile_id(@profile1.id).to_status, 'participated_in_the_future'
    assert_equal LoveFundRecord.find_by_user_id(@profile1.user_id).participate, true


    get love_funds_url, params: { sort_column: :participate, sort_direction: :desc }
    assert_response :success
    assert_equal json_res['data'][0]['is_participate'], false

    patch "/profiles/#{@profile1.id}/love_fund", params: {
      to_status: 'not_participated_in_the_future',
      valid_date: Time.zone.now
    }
    assert_equal LoveFund.find_by_profile_id(@profile1.id).to_status, 'not_participated_in_the_future'
    assert_equal LoveFundRecord.where(user_id: @profile1.user_id).order(created_at: :desc).first.participate, false
    assert_equal LoveFundRecord.where(user_id: @profile1.user_id).order(created_at: :asc).first.participate, true
    assert_equal LoveFundRecord.where(user_id: @profile1.user_id).order(created_at: :asc).first.participate_end.to_s.to_date, Time.zone.now.to_date

  end

  test "should get index" do
    LoveFundsController.any_instance.stubs(:current_user).returns(@another_user)
    get love_funds_url
    assert_response 403
    LoveFundsController.any_instance.stubs(:current_user).returns(@current_user)
    get love_funds_url
    assert_response :success

    # 员工编号
    get love_funds_url, params: { empoid: User.find(@profile1.user_id).empoid }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 员工姓名
    get love_funds_url, params: { user: User.find(@profile1.user_id).chinese_name }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get love_funds_url, params: { sort_column: :user, sort_direction: :desc}
    assert_response :success

    # 部门
    get love_funds_url, params: { departments: User.find(@profile1.user_id).department_id }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 职位
    get love_funds_url, params: { positions: User.find(@profile1.user_id).position_id }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 职级
    get love_funds_url, params: { grades: @profile1[:data]['position_information']['field_values']['grade'] }
    assert_response :success
    assert json_res['data'].count >= 1

    # 入职日期
    range = { begin: Date.tomorrow.to_s.gsub('-','/'), end: (Date.tomorrow+1.month).to_s.gsub('-','/') }
    get love_funds_url, params: { date_of_employment: range }
    assert_response :success
    assert_equal 0, json_res['data'].count

    range = { begin: 10.year.ago.to_date.to_s.gsub('-','/'), end: Date.today.to_s.gsub('-','/') }
    get love_funds_url, params: { date_of_employment: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 是否参加
    get love_funds_url, params: { participate: 'not_participated' }
    assert_response :success
    assert_equal 2, json_res['data'].count

    get love_funds_url, params: { sort_column: :participate, sort_direction: :desc}
    assert_response :success

    # 参加日期
    range = { begin: '2017/01/01', end: '2017/01/05' }
    get love_funds_url, params: { participate_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 取消日期
    range = { begin: '2017/04/01', end: '2017/04/01' }
    get love_funds_url, params: { cancel_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count
  end

  test "get index sorted" do
    sort_column = 'monthly_deduction'
    LoveFundsController.any_instance.stubs(:current_user).returns(@another_user)
    get love_funds_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response 403
    LoveFundsController.any_instance.stubs(:current_user).returns(@current_user)
    get love_funds_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get love_funds_url, params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  test 'get show' do
    get "/profiles/#{@profile1.id}/love_fund"
    assert_response :ok
    assert_equal json_res['data']['participate'], 'participated'
  end

  test 'get show profile has had suncity_charity' do
    create(:love_fund, profile_id: @test_profile.id, participate: 'participated')
    get "/profiles/#{@test_profile.id}/love_fund"
    assert_response :ok
    assert_equal json_res['data']['participate'], 'participated'

  end

  test 'patch update profile without suncity_charity' do
    LoveFundsController.any_instance.stubs(:current_user).returns(@another_user)
    patch "/profiles/#{@test_profile.id}/love_fund", params: {
      to_status: 'not_participated_in_the_future',
      valid_date: '2014/05/06'
    }
    assert_response 403
    LoveFundsController.any_instance.stubs(:current_user).returns(@current_user)
    patch "/profiles/#{@test_profile.id}/love_fund", params: {
        to_status: 'not_participated_in_the_future',
        valid_date: '2014/05/06'
    }
    assert_response :ok
    assert_equal json_res['data'], 'love_fund is null'
  end


  # test "should batch update" do
  #   patch '/love_funds/batch_update', params: { ids: [@profile1.user_id, @profile2.user_id],
  #                                               love_fund: {
  #                                                   to_status: 'not_participated_in_the_future',
  #                                                   valid_date: '2014/05/06'} }
  #   assert_response :success
  #   assert_equal LoveFund.where(user_id: @profile1.user_id).first.to_status, 'not_participated_in_the_future'
  #   assert_equal LoveFund.where(user_id: @profile1.user_id).first.cancel_date.to_date, Date.parse('2017/04/01')
  #
  #   patch '/love_funds/batch_update', params: { ids: [@profile1.user_id, @profile2.user_id],
  #                                               love_fund: {
  #                                                   to_status: 'participated_in_the_future',
  #                                                   valid_date: Time.zone.now} }
  #   assert_response :success
  #   assert_equal LoveFund.where(user_id: @profile1.user_id).first.to_status, 'participated_in_the_future'
  # end

  test "should export" do
    LoveFundsController.any_instance.stubs(:current_user).returns(@another_user)
    get '/love_funds/export', params: { sort_column: 'date_of_employment', sort_direction: :asc }
    assert_response 403
    LoveFundsController.any_instance.stubs(:current_user).returns(@current_user)
    get '/love_funds/export', params: { sort_column: 'date_of_employment', sort_direction: :asc }
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/xlsx', response.content_type
    assert_response :success
  end

  test "should get field options" do
    get '/love_funds/field_options'
    assert_response :success
    response_record = json_res['data']
    assert_not_nil response_record['positions']
    assert_not_nil response_record['departments']
    assert_not_nil response_record['grades']
    assert_not_nil response_record['participate']
  end

  test 'can_create' do
    test_user = create_test_user
    ProfileService.stubs(:date_of_employment).with(any_parameters).returns(Time.zone.now.beginning_of_day)
    get can_create_profile_love_fund_url(profile_id: test_user.profile.id, join_date: (Time.zone.now + 1.day).strftime('%Y/%m/%d'))
    assert @response.body
    get can_create_profile_love_fund_url(profile_id: test_user.profile.id, join_date: (Time.zone.now - 1.day).strftime('%Y/%m/%d'))
    assert_equal  @response.body , 'false'
    get can_create_profile_love_fund_url(profile_id: test_user.profile.id, join_date: nil)
    assert_response 422
  end

end
