require 'test_helper'

class VipHallsTrainersControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(:location, id: 61, chinese_name: '新葡京', english_name: 'New lisboa', simple_chinese_name: '新葡京')
    create(:location, id: 62, chinese_name: '威尼斯人', english_name: 'The Venetian', simple_chinese_name: '威尼斯人')
    create(:location, id: 63, chinese_name: '金沙', english_name: 'Jin Sha', simple_chinese_name: '金沙')

    create(:vip_halls_train, id: 51, location_id: 61, train_month: '2017/09', locked: false, employee_amount: 300, training_minutes_available: 0, training_minutes_accepted: 0, training_minutes_per_employee: 0)
    create(:vip_halls_train, id: 52, location_id: 61, train_month: '2017/06', locked: true, employee_amount: 300, training_minutes_available: 8000, training_minutes_accepted: 6000, training_minutes_per_employee: 20)
    create(:vip_halls_train, id: 53, location_id: 61, train_month: '2017/05', locked: true, employee_amount: 300, training_minutes_available: 0, training_minutes_accepted: 0, training_minutes_per_employee: 0)
    create(:vip_halls_train, id: 54, location_id: 62, train_month: '2017/06', locked: true, employee_amount: 300, training_minutes_available: 8000, training_minutes_accepted: 6000, training_minutes_per_employee: 20)

    @user1 = create_test_user
    @user2 = create_test_user
    @user3 = create_test_user
    create(:user, location_id: 61)
    create(:user, location_id: 61)
    create(:user, location_id: 61)
    create(:user, location_id: 61)
    create(:user, location_id: 62)
    create(:user, location_id: 62)
    create(:user, location_id: 62)

    create(:vip_halls_trainer, id: 101, vip_halls_train_id: 51, train_date_begin: '2017/10/01 09:00', train_date_end: '2017/10/01 16:00', length_of_training_time: 420, train_content: '電話服務訓練',
           user_id: @user1.id, train_type: 'group_training', number_of_students: 20, total_accepted_training_time: 8400, remarks: '备注1')
    create(:vip_halls_trainer, id: 102, vip_halls_train_id: 51, train_date_begin: '2017/10/03 09:00', train_date_end: '2017/10/03 16:00', length_of_training_time: 420, train_content: '甜品装裱訓練',
           user_id: @user2.id, train_type: 'group_training', number_of_students: 10, total_accepted_training_time: 4200, remarks: '备注2')
    create(:vip_halls_trainer, id: 103, vip_halls_train_id: 51, train_date_begin: '2017/09/25 09:00', train_date_end: '2017/09/25 11:00', length_of_training_time: 120, train_content: 'CEO养成计划',
           user_id: @user3.id, train_type: 'individual_training', number_of_students: 1, total_accepted_training_time: 120, remarks: 'CEO备注')

    create(:vip_halls_trainer, id: 104, vip_halls_train_id: 54, train_date_begin: '2017/06/01 09:00', train_date_end: '2017/06/01 16:00', length_of_training_time: 420, train_content: '電話服務訓練',
           user_id: @user1.id, train_type: 'group_training', number_of_students: 20, total_accepted_training_time: 8400, remarks: '备注1')
    create(:vip_halls_trainer, id: 105, vip_halls_train_id: 54, train_date_begin: '2017/06/03 09:00', train_date_end: '2017/06/03 16:00', length_of_training_time: 420, train_content: '甜品装裱訓練',
           user_id: @user2.id, train_type: 'group_training', number_of_students: 10, total_accepted_training_time: 4200, remarks: '备注2')
    create(:vip_halls_trainer, id: 106, vip_halls_train_id: 54, train_date_begin: '2017/04/25 09:00', train_date_end: '2017/04/25 11:00', length_of_training_time: 120, train_content: 'CEO养成计划',
           user_id: @user3.id, train_type: 'individual_training', number_of_students: 1, total_accepted_training_time: 120, remarks: 'CEO备注')
    create(:vip_halls_trainer, id: 107, vip_halls_train_id: 54, train_date_begin: '2017/05/25 09:00', train_date_end: '2017/05/25 12:00', length_of_training_time: 180, train_content: 'COO养成计划',
           user_id: @user3.id, train_type: 'individual_training', number_of_students: 1, total_accepted_training_time: 180, remarks: 'COO备注')

    @trainer = create(:vip_halls_trainer, id: 108, vip_halls_train_id: 52, train_date_begin: '2017/05/25 09:00', train_date_end: '2017/05/25 12:00', length_of_training_time: 180,
                      train_content: 'COO养成计划', user_id: @user3.id, train_type: 'individual_training', number_of_students: 1, total_accepted_training_time: 180, remarks: 'COO备注')
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    @user3.add_role(admin_role)
    VipHallsTrainersController.any_instance.stubs(:current_user).returns(@user3)
    VipHallsTrainsController.any_instance.stubs(:current_user).returns(@user3)
  end

  test "should get index" do
    # hr，详情页有记录
    get vip_halls_trainers_url, params: { inspector: 'hr', vip_halls_train_id: 51 }
    assert_response :success
    assert_equal 3, json_res['data'].count
    assert_equal 300, json_res['meta']['header_number_of_people_on_the_1st_day']
    assert_equal 960, json_res['meta']['header_total_training_time_provided']
    assert_equal 12720, json_res['meta']['header_total_training_time_accepted']
    assert_equal 42, json_res['meta']['header_average_training_time_accepted']
    assert_equal 1, json_res['meta']['header_score']
    assert_equal false, json_res['meta']['locked']

    # hr，详情页无记录
    get vip_halls_trainers_url, params: { inspector: 'hr', vip_halls_train_id: 53 }
    assert_response :success
    assert_equal 0, json_res['data'].count
    assert_equal 300, json_res['meta']['header_number_of_people_on_the_1st_day']
    assert_equal 0, json_res['meta']['header_total_training_time_provided']
    assert_equal 0, json_res['meta']['header_total_training_time_accepted']
    assert_equal 0, json_res['meta']['header_average_training_time_accepted']
    assert_equal 1, json_res['meta']['header_score']
    assert_equal true, json_res['meta']['locked']

    # department，只给location_id，详情页有记录
    get vip_halls_trainers_url, params: { inspector: 'department', location_id: 61 }
    assert_response :success
    assert_equal 3, json_res['data'].count
    assert_equal 300, json_res['meta']['header_number_of_people_on_the_1st_day']
    assert_equal 960, json_res['meta']['header_total_training_time_provided']
    assert_equal 12720, json_res['meta']['header_total_training_time_accepted']
    assert_equal 42, json_res['meta']['header_average_training_time_accepted']
    assert_equal 1, json_res['meta']['header_score']
    assert_equal false, json_res['meta']['locked']

    # department，给location_id/train_month，详情页有记录
    get vip_halls_trainers_url, params: { inspector: 'department', location_id: 62, train_month: '2017/06' }
    assert_response :success
    assert_equal 4, json_res['data'].count
    assert_equal 300, json_res['meta']['header_number_of_people_on_the_1st_day']
    assert_equal 1140, json_res['meta']['header_total_training_time_provided']
    assert_equal 12900, json_res['meta']['header_total_training_time_accepted']
    assert_equal 43, json_res['meta']['header_average_training_time_accepted']
    assert_equal 1, json_res['meta']['header_score']
    assert_equal true, json_res['meta']['locked']

    # department，给location_id/train_month，详情页无记录
    get vip_halls_trainers_url, params: { inspector: 'department', location_id: 61, train_month: '2017/05' }
    assert_response :success
    assert_equal 0, json_res['data'].count
    assert_equal 300, json_res['meta']['header_number_of_people_on_the_1st_day']
    assert_equal 0, json_res['meta']['header_total_training_time_provided']
    assert_equal 0, json_res['meta']['header_total_training_time_accepted']
    assert_equal 0, json_res['meta']['header_average_training_time_accepted']
    assert_equal 1, json_res['meta']['header_score']
    assert_equal true, json_res['meta']['locked']
  end

  test "should get columns" do
    get columns_vip_halls_trainers_url
    assert_response 200
  end

  test "should export 1.0" do
    get export_vip_halls_trainers_url, params: { inspector: 'hr', vip_halls_train_id: 54 }
    assert_response 200
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
  end

  test "should export 2.0" do
    get export_vip_halls_trainers_url, params: { inspector: 'department', location_id: 62 }
    assert_response 200
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
  end

  test "should export 3.0" do
    # 无记录的汇出
    get export_vip_halls_trainers_url, params: { inspector: 'hr', vip_halls_train_id: 53 }
    assert_response 200
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
  end

  test "create 1.0" do
    # 集体培训
    post vip_halls_trainers_url, params: { vip_halls_trainer: {
        vip_halls_train_id: 51,
        train_date_begin: '2017/06/01 09:00',
        train_date_end: '2017/06/01 16:00',
        train_content: '培训内容',
        user_id: @user1.id,
        train_type: 'group_training',
        number_of_students: 20,
        remarks: '备注',
    } }
    assert_response :success
    target = VipHallsTrainer.find(json_res['data']['id'])
    assert_equal Time.zone.parse('2017/06/01 09:00'), target.train_date_begin
    assert_equal Time.zone.parse('2017/06/01 16:00'), target.train_date_end
    assert_equal 420, target.length_of_training_time
    assert_equal '培训内容', target.train_content
    assert_equal 'group_training', target.train_type
    assert_equal 20, target.number_of_students
    assert_equal 8400, target.total_accepted_training_time
    assert_equal '备注', target.remarks
    # after_create
    assert_equal 1380, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_available
    assert_equal 21120, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_accepted
    assert_equal 70, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_per_employee
  end

  test "create 2.0" do
    # 个体培训
    post vip_halls_trainers_url, params: { vip_halls_trainer: {
        vip_halls_train_id: 51,
        train_date_begin: '2017/06/01 09:00',
        train_date_end: '2017/06/01 16:00',
        train_content: '培训内容',
        user_id: @user1.id,
        train_type: 'individual_training',
        number_of_students: 1,
        remarks: '备注',
    } }
    assert_response :success
    target = VipHallsTrainer.find(json_res['data']['id'])
    assert_equal Time.zone.parse('2017/06/01 09:00'), target.train_date_begin
    assert_equal Time.zone.parse('2017/06/01 16:00'), target.train_date_end
    assert_equal 420, target.length_of_training_time
    assert_equal '培训内容', target.train_content
    assert_equal 'individual_training', target.train_type
    assert_equal 1, target.number_of_students
    assert_equal 420, target.total_accepted_training_time
    assert_equal '备注', target.remarks
    # after_create
    assert_equal 1380, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_available
    assert_equal 13140, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_accepted
    assert_equal 43, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_per_employee
  end

  test "update" do
    patch vip_halls_trainer_url(@trainer.id), params: { vip_halls_trainer: {
        train_date_begin: '2017/05/25 15:00',
        train_date_end: '2017/05/25 17:00',
        train_content: '健身授课方式培训',
        user_id: @user1.id,
        train_type: 'group_training',
        number_of_students: 99,
        remarks: '健身培训备注'
    } }
    assert_response 200
    target = VipHallsTrainer.find(@trainer.id)
    assert_equal Time.zone.parse('2017/05/25 15:00'), target.train_date_begin
    assert_equal Time.zone.parse('2017/05/25 17:00'), target.train_date_end
    assert_equal '健身授课方式培训', target.train_content
    assert_equal @user1.id, target.user_id
    assert_equal 'group_training', target.train_type
    assert_equal 99, target.number_of_students
    assert_equal '健身培训备注', target.remarks
    # after_update
    assert_equal 180, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_available
    assert_equal 180, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_accepted
    assert_equal 0, VipHallsTrain.find(target.vip_halls_train_id).training_minutes_per_employee
  end

  test "month_options" do
    get month_options_vip_halls_trainers_url, params: { location_id: 61 }
    assert_response 200
    assert_equal 3, json_res['data'].count
  end

end
