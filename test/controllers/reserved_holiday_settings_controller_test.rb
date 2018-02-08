require 'test_helper'

class ReservedHolidaySettingsControllerTest < ActionDispatch::IntegrationTest

  setup do
    profile = create_profile
    @user = profile.user
    @reserved_holiday_setting = create(:reserved_holiday_setting, chinese_name: '假期A',
           english_name: 'Holiday A',
           simple_chinese_name: '假期A',
           date_begin: '2017/11/10',
           date_end: '2017/11/12',
           days_count: 5,
           creator_id: @user.id
    )
  end

  def test_index
    get reserved_holiday_settings_url, as: :json
    assert_response :success
  end

  def test_create
    assert_difference('ReservedHolidaySetting.count') do
      create_params = {
        chinese_name: '假期B',
        english_name: 'Holiday B',
        simple_chinese_name: '假期B',
        date_begin: '2017/11/10',
        date_end: '2017/11/12',
        days_count: 5,
        creator_id: @user.id
      }
      post reserved_holiday_settings_url, params: create_params
      assert_response :success
    end

    assert_difference('ReservedHolidaySetting.count') do
      create_params = {
          chinese_name: '假期B',
          #english_name: 'Holiday B',
          simple_chinese_name: '假期B',
          date_begin: '2017/11/10',
          date_end: '2017/11/12',
          days_count: 5,
          creator_id: @user.id
      }
      post reserved_holiday_settings_url, params: create_params
      assert_response 422
      assert_equal json_res['data'][0]['message'], '參數不完整'
    end
  end

  def test_show
    get reserved_holiday_setting_url(@reserved_holiday_setting)
    assert_response :success
  end

  def test_update
    update_params = {
      chinese_name: '假期B',
      english_name: 'Holiday B',
      simple_chinese_name: '假期B',
      date_begin: '2017/11/10',
      date_end: '2017/11/12',
      days_count: 5,
      creator_id: @user.id
    }
    patch reserved_holiday_setting_url(@reserved_holiday_setting), params: update_params
    assert_response 200

    setting = ReservedHolidaySetting.find(@reserved_holiday_setting.id)
    assert_equal setting.chinese_name, '假期B'

    update_params = {
        chinese_name: '假期B',
        #english_name: 'Holiday B',
        simple_chinese_name: '假期B',
        date_begin: '2017/11/10',
        date_end: '2017/11/12',
        days_count: 5,
        creator_id: @user.id
    }
    patch reserved_holiday_setting_url(@reserved_holiday_setting), params: update_params
    assert_response 422
    assert_equal json_res['data'][0]['message'], '參數不完整'
  end

  def test_destroy
    assert_difference('ReservedHolidaySetting.count', -1) do
      delete reserved_holiday_setting_url(@reserved_holiday_setting)
    end
    assert_response 204
  end
end
