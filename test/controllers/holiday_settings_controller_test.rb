# coding: utf-8
require "test_helper"

class HolidaySettingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :HolidaySetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    HolidaySettingsController.any_instance.stubs(:current_user).returns(user)
  end


  test "get index without params" do
    [*1..20].each do |i|
      holiday_setting = create(:holiday_setting)
      holiday_setting.holiday_date = i % 3 == 0 ? '2017/01/01' : '2016/12/31'
      holiday_setting.save
    end

    get '/holiday_settings'
    assert_response :success

    assert_equal [*1..20].select { |i| i % 3 == 0 }.count, json_res['data'].count
  end

  test "get index with params year" do
    [*1..20].each do |i|
      holiday_setting = create(:holiday_setting)
      holiday_setting.holiday_date = i % 3 == 0 ? '2017/01/01' : '2016/12/31'
      holiday_setting.save
    end

    params = {
      year: 2016
    }

    get '/holiday_settings', params: params
    assert_response :success

    assert_equal [*1..20].select { |i| i % 3 != 0 }.count, json_res['data'].count
  end

  test "get index with params year & month" do
    [*1..20].each do |i|
      holiday_setting = create(:holiday_setting)
      holiday_setting.holiday_date =
        if i % 3 == 0
          '2016/01/01'
        elsif i % 3 == 1
          '2016/12/31'
        else
          '2017/01/01'
        end
      holiday_setting.save
    end

    params = {
      year: '2016',
      month: '1',
    }

    get '/holiday_settings', params: params
    assert_response :success

    assert_equal [*1..20].select { |i| i % 3 == 0 }.count, json_res['data'].count
  end

  test 'should create' do
    params = {
      region: 'macau',
      chinese_name: '假期 1',
      english_name: 'holiday 1',
      simple_chinese_name: '假期 1',
      category: 0,
      holiday_date: '2017/01/01',
    }

    assert_difference(['HolidaySetting.count'], 1) do
      post "/holiday_settings", params: params, as: :json
      assert_response :success
    end

    params = {
        region: 'macau',
        #chinese_name: '假期 1',
        english_name: 'holiday 1',
        simple_chinese_name: '假期 1',
        category: 0,
        holiday_date: '2017/01/01',
    }

    assert_difference(['HolidaySetting.count'], 1) do
      post "/holiday_settings", params: params, as: :json
      assert_response 422
      assert_equal json_res['data'][0]['message'], '參數不完整'
    end
  end

  test 'should update' do
    hs = create(:holiday_setting)

    params = {
      holiday_date: '2017/06/01',
    }

    put "/holiday_settings/#{hs.id}", params: params, as: :json
    assert_response :success

    assert_equal '2017/06/01', HolidaySetting.first.holiday_date.strftime("%Y/%m/%d")
  end

  test "should destroy" do
    hs = create(:holiday_setting)

    assert_difference(['HolidaySetting.count'], -1) do
      delete "/holiday_settings/#{hs.id}"
      assert_response :success
    end
  end

  test "should batch create" do
    params = {
      holidays: [
        {
          region: 'macau',
          chinese_name: '假期 1',
          english_name: 'holiday 1',
          simple_chinese_name: '假期 1',
          category: 0,
          holiday_date: '2017/01/01',
        },
        {
          region: 'macau',
          chinese_name: '假期 2',
          english_name: 'holiday 2',
          simple_chinese_name: '假期 2',
          category: 0,
          holiday_date: '2017/05/01',
        },

        {
          region: 'macau',
          chinese_name: '假期 3',
          english_name: 'holiday 3',
          simple_chinese_name: '假期 3',
          category: 1,
          holiday_date: '2017/10/01',
        },
      ]
    }

    assert_difference(['HolidaySetting.count'], 3) do
      post "/holiday_settings/batch_create", params: params, as: :json
      assert_response :success
    end

    params = {
        holidays: [
            {
                region: 'macau',
                #chinese_name: '假期 1',
                english_name: 'holiday 1',
                simple_chinese_name: '假期 1',
                category: 0,
                holiday_date: '2017/01/01',
            },
            {
                region: 'macau',
                chinese_name: '假期 2',
                english_name: 'holiday 2',
                #simple_chinese_name: '假期 2',
                category: 0,
                holiday_date: '2017/05/01',
            },

            {
                region: 'macau',
                chinese_name: '假期 3',
                english_name: 'holiday 3',
                simple_chinese_name: '假期 3',
                #category: 1,
                holiday_date: '2017/10/01',
            },
        ]
    }

    assert_difference(['HolidaySetting.count'], 3) do
      post "/holiday_settings/batch_create", params: params, as: :json
      assert_response 422
      assert_equal json_res['data'][0]['message'], '參數不完整'
    end
  end

end
