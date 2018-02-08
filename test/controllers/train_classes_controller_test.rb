require 'test_helper'

class TrainClassesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @train_template_type1 = create(:train_template_type, chinese_name: 'HR培訓',  english_name: 'HR Training',         simple_chinese_name: 'HR培训')
    @train_template_type2 = create(:train_template_type, chinese_name: '場面培訓', english_name: 'Scene Training',      simple_chinese_name: '现场培训')
    @train_template_type3 = create(:train_template_type, chinese_name: '賬房培訓', english_name: 'Accountant Training', simple_chinese_name: '账房培训')

    @train_template1 = create(:train_template, train_template_type_id: @train_template_type1.id, online_or_offline_training: 'offline_training', training_credits: '1.0')
    @train_template2 = create(:train_template, train_template_type_id: @train_template_type2.id, online_or_offline_training: 'online_training',  training_credits: '1.0')
    @train_template3 = create(:train_template, train_template_type_id: @train_template_type3.id, online_or_offline_training: 'offline_training', training_credits: '1.0')

    @train1 = create(:train, train_template_id: @train_template1.id, chinese_name: '電話服務培訓', english_name: 'Telephone service training', train_number: '001', registration_method: 'by_employee',
                     train_date_begin: '2017/06/01', train_date_end: '2017/06/03', registration_date_begin: '2017/05/15', registration_date_end: '2017/05/17')
    @train2 = create(:train, train_template_id: @train_template2.id, chinese_name: '论文写作培訓', english_name: 'Thesis writing training',  train_number: '002', registration_method: 'by_employee',
                     train_date_begin: '2017/07/01', train_date_end: '2017/07/03', registration_date_begin: '2017/05/15', registration_date_end: '2017/05/17')
    @train3 = create(:train, train_template_id: @train_template3.id, chinese_name: '甜品制作培訓', english_name: 'Sweetmeats training',        train_number: '003', registration_method: 'by_employee',
                     train_date_begin: '2017/08/01', train_date_end: '2017/08/03', registration_date_begin: '2017/05/15', registration_date_end: '2017/05/17')

    @title1 = create(:title, name: 'A', col: 1, train_id: @train1.id)
    @title2 = create(:title, name: 'B', col: 2, train_id: @train2.id)
    @title3 = create(:title, name: 'C', col: 3, train_id: @train3.id)

    @train_class1 = create(:train_class, time_begin: '2017/06/01 19:00', time_end: '2017/06/01 20:00', title_id: @title1.id, train_id: @train1.id)
    @train_class2 = create(:train_class, time_begin: '2017/07/02 19:00', time_end: '2017/07/02 20:00', title_id: @title2.id, train_id: @train2.id)
    @train_class3 = create(:train_class, time_begin: '2017/08/03 19:00', time_end: '2017/08/03 20:00', title_id: @title3.id, train_id: @train3.id)

    #################################################################

    @department1 = create(:department, chinese_name: '行政及人力資源部')
    @department2 = create(:department, chinese_name: '網絡及系統副總監')

    @user1 = create(:user, department_id: @department1.id)
    @user2 = create(:user, department_id: @department1.id)
    @user3 = create(:user, department_id: @department1.id)
    @user4 = create(:user, department_id: @department2.id)
    @user5 = create(:user, department_id: @department2.id)
    TrainClassesController.any_instance.stubs(:current_user).returns(@user1)

    @entry1 = create(:entry_list, user_id: @user1.id, train_id: @train1.id, creator_id: @user1.id, registration_status: 0)
    @entry2 = create(:entry_list, user_id: @user2.id, train_id: @train1.id, creator_id: @user1.id, registration_status: 0)
    @entry3 = create(:entry_list, user_id: @user3.id, train_id: @train1.id, creator_id: @user1.id, registration_status: 0)
    @entry4 = create(:entry_list, user_id: @user4.id, train_id: @train1.id, creator_id: @user1.id, registration_status: 0)
    create(:final_list, user_id: @user1.id, train_id: @train1.id, entry_list_id: @entry1.id)
    create(:final_list, user_id: @user2.id, train_id: @train1.id, entry_list_id: @entry2.id)
    create(:final_list, user_id: @user4.id, train_id: @train1.id, entry_list_id: @entry4.id)

    @entry4 = create(:entry_list, user_id: @user1.id, train_id: @train2.id, creator_id: @user1.id, registration_status: 0)
    @entry5 = create(:entry_list, user_id: @user4.id, train_id: @train2.id, creator_id: @user1.id, registration_status: 0)
    @entry6 = create(:entry_list, user_id: @user5.id, train_id: @train2.id, creator_id: @user1.id, registration_status: 0)
    create(:final_list, user_id: @user1.id, train_id: @train2.id, entry_list_id: @entry4.id)
    create(:final_list, user_id: @user4.id, train_id: @train2.id, entry_list_id: @entry5.id)
    create(:final_list, user_id: @user5.id, train_id: @train2.id, entry_list_id: @entry6.id)

    @department1.train_classes << @train_class1
    @user1.train_classes << @train_class1
    @user1.train_classes << @train_class2

    @department1.trains << @train1
    @user1.trains << @train1
    @user1.trains << @train2
  end

  def test_index
    # 培训记录-培训月历
    get train_classes_url, params: { by_whom: 'by_hr', year_month: '2017/06' }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 部门的培训-培训月历
    get train_classes_url, params: { by_whom: 'by_department', year_month: '2017/06' }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 我的培训-培训月历
    get train_classes_url, params: { by_whom: 'by_mine', year_month: '2017/06' }
    assert_response :success
    assert_equal 2, json_res['data'].count
  end

  def test_index_classes
    # 部门的培训-培训课程
    get index_trains_train_classes_url, params: { by_whom: 'by_department' }
    assert_response :success

    # 我的培训-培训课程
    get index_trains_train_classes_url, params: { by_whom: 'by_mine' }
    assert_response :success

    # 培训日期
    range = { begin: '2017/06/01', end: '2017/06/30' }
    get index_trains_train_classes_url, params: { by_whom: 'by_mine', train_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 报名日期
    range = { begin: '2017/05/01', end: '2017/05/30' }
    get index_trains_train_classes_url, params: { by_whom: 'by_mine', registration_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 报名方式
    get index_trains_train_classes_url, params: { by_whom: 'by_mine', registration_method: 'by_employee' }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 线上/线下培训
    get index_trains_train_classes_url, params: { by_whom: 'by_mine', online_or_offline_training: 'offline_training' }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 培训种类
    get index_trains_train_classes_url, params: { by_whom: 'by_mine', train_template_type_id: @train_template_type1.id }
    assert_response :success
    assert_equal 0, json_res['data'].count

    # 培训学分
    get index_trains_train_classes_url, params: { by_whom: 'by_mine', training_credits: '1.0' }
    assert_response :success
    assert_equal 0, json_res['data'].count
  end

end
