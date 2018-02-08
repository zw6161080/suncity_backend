require 'test_helper'

class VipHallsTrainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(:location, id: 1, chinese_name: '新葡京', english_name: 'New lisboa', simple_chinese_name: '新葡京')
    create(:location, id: 2, chinese_name: '威尼斯人', english_name: 'The Venetian', simple_chinese_name: '威尼斯人')
    create(:location, id: 3, chinese_name: '金沙', english_name: 'Jin Sha', simple_chinese_name: '金沙')

    create(:vip_halls_train, id: 51, location_id: 1, train_month: '2017/09', locked: false, employee_amount: 300, training_minutes_available: 0, training_minutes_accepted: 0, training_minutes_per_employee: 0)
    create(:vip_halls_train, id: 52, location_id: 2, train_month: '2017/09', locked: false, employee_amount: 200, training_minutes_available: 0, training_minutes_accepted: 0, training_minutes_per_employee: 0)
    create(:vip_halls_train, id: 53, location_id: 3, train_month: '2017/09', locked: false, employee_amount: 500, training_minutes_available: 0, training_minutes_accepted: 0, training_minutes_per_employee: 0)

    create(:vip_halls_train, id: 54, location_id: 1, train_month: '2017/06', locked: true, employee_amount: 300, training_minutes_available: 8000, training_minutes_accepted: 6000, training_minutes_per_employee: 20)
    create(:vip_halls_train, id: 55, location_id: 2, train_month: '2017/06', locked: true, employee_amount: 200, training_minutes_available: 6000, training_minutes_accepted: 4000, training_minutes_per_employee: 20)
    create(:vip_halls_train, id: 56, location_id: 3, train_month: '2017/06', locked: true, employee_amount: 500, training_minutes_available: 9000, training_minutes_accepted: 5000, training_minutes_per_employee: 10)

    create(:vip_halls_train, id: 57, location_id: 1, train_month: '2017/05', locked: true, employee_amount: 300, training_minutes_available: 0, training_minutes_accepted: 0, training_minutes_per_employee: 0)
    create(:vip_halls_train, id: 58, location_id: 2, train_month: '2017/05', locked: true, employee_amount: 300, training_minutes_available: 9000, training_minutes_accepted: 9000, training_minutes_per_employee: 30)
    create(:vip_halls_train, id: 59, location_id: 3, train_month: '2017/05', locked: true, employee_amount: 500, training_minutes_available: 5000, training_minutes_accepted: 0, training_minutes_per_employee: 0)

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    user.update_columns(location_id: 0)
    VipHallsTrainersController.any_instance.stubs(:current_user).returns(user)
    VipHallsTrainsController.any_instance.stubs(:current_user).returns(user)
    VipHallsTrainsController.any_instance.stubs(:authorize).returns(true)

  end

  test "gets index" do
    get vip_halls_trains_url
    assert_response :success
    assert_equal 9, json_res['data'].count

    get vip_halls_trains_url, params: { location_id: 1 }
    assert_response :success
    assert_equal 3, json_res['data'].count
    json_res['data'].each do |record|
      assert_equal 1, record['location_id']
    end

    get vip_halls_trains_url, params: { train_month: '2017/05' }
    assert_response :success
    assert_equal 3, json_res['data'].count
    json_res['data'].each do |record|
      assert_equal Time.zone.parse('2017/05'), record['train_month']
    end
  end

  test "create" do
    post vip_halls_trains_url, params: { vip_halls_train: { train_month: '2017/10', location_ids: [1,2,3] } }
    assert_response :success
    VipHallsTrain.find(json_res['data']).each do |train|
      assert_equal true, [1,2,3].include?(train.location_id)
      assert_equal Time.zone.parse('2017/10'), train.train_month
      assert_equal false, train.locked
      assert_equal 0, train.employee_amount
      assert_equal 0, train.training_minutes_available
      assert_equal 0, train.training_minutes_accepted
      assert_equal 0, train.training_minutes_per_employee
    end
  end

  test "field_options" do
    get field_options_vip_halls_trains_url
    assert_response 200
  end

  test "options_of_all_locations" do
    get options_of_all_locations_vip_halls_trains_url
    assert_response 200
  end

  test "which_locations_can_be_chosen" do
    get which_locations_can_be_chosen_vip_halls_trains_url, params: { train_month: '2017/06' }
    assert_response 200
  end

  test "lock" do
    patch '/vip_halls_trains/51/lock'
    assert_response 200
    assert_equal true, VipHallsTrain.find(51).locked
  end

end
