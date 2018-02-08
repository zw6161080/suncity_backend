require 'test_helper'

class TrainingAbsenteesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @train1 = create(:train, id: 1001, chinese_name: '電話服務培訓', english_name: 'Telephone service training', train_number: '001', train_date_begin: '2017/06/01', train_date_end: '2017/06/03')
    @train2 = create(:train, id: 1002, chinese_name: '论文写作培訓', english_name: 'Thesis writingce training',  train_number: '002', train_date_begin: '2017/07/01', train_date_end: '2017/07/03')
    @train3 = create(:train, id: 1003, chinese_name: '甜品制作培訓', english_name: 'Sweetmeats training',        train_number: '003', train_date_begin: '2017/08/01', train_date_end: '2017/08/03')

    create(:title, id: 10001, name: 'A', train_id: 1001, col: 1)
    create(:title, id: 10002, name: 'B', train_id: 1002, col: 2)
    create(:title, id: 10003, name: 'C', train_id: 1003, col: 3)

    @train_class1 = create(:train_class, id: 1001, time_begin: '2017/06/01 19:00', time_end: '2017/06/01 20:00', title_id: 10001, train_id: 1001)
    @train_class2 = create(:train_class, id: 1002, time_begin: '2017/07/02 19:00', time_end: '2017/07/02 20:00', title_id: 10002, train_id: 1002)
    @train_class3 = create(:train_class, id: 1003, time_begin: '2017/08/03 19:00', time_end: '2017/08/03 20:00', title_id: 10003, train_id: 1003)

    @user1 = create_test_user
    @user2 = create_test_user
    @user3 = create_test_user

    create(:training_absentee, id: 101, user_id: @user1.id, train_class_id: 1001,
           has_submitted_reason: false, has_been_exempted: true, absence_reason: nil, submit_date: nil)
    create(:training_absentee, id: 102, user_id: @user2.id, train_class_id: 1002,
           has_submitted_reason: true,  has_been_exempted: false, absence_reason: '缺席原因1', submit_date: '2017/07/05 12:00')
    create(:training_absentee, id: 103, user_id: @user3.id, train_class_id: 1003,
           has_submitted_reason: true,  has_been_exempted: false, absence_reason: '缺席原因2', submit_date: '2017/08/05 12:00')
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :TrainingAbsentee, :macau)
    @user3.add_role(admin_role)
    TrainingAbsenteesController.any_instance.stubs(:current_user).returns(@user3)
    TrainingAbsenteesController.any_instance.stubs(:authorize).returns(true)

  end

  test "get index" do
    get training_absentees_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      TrainingAbsentee.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "get index sorted" do
    sort_column = 'train_class_time'
    get "#{training_absentees_url}.json", params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get "#{training_absentees_url}.json", params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  test "should get columns" do
    get columns_training_absentees_url
    assert_response :success
    assert json_res.count > 0
    assert json_res.all? do |col|
      client_attributes = Config
                              .get('report_column_client_attributes')
                              .fetch('attributes', [])
      assert col.keys.to_set.subset?(client_attributes.to_set)
    end
  end

  test "should get options" do
    get options_training_absentees_url
    assert_response :success
    TrainingAbsentee.statement_columns.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
        # train_name: ['電話服務培訓'],
        # has_submitted_reasocn: [false],
        # has_been_exempted: [false],
        # train_number: '001',
        # train_date: { begin: '2017/08/01', end: '' },
        # train_class_time: { begin: '2017/07/01', end: '' },
        # submit_date: { begin: '2017/07/01', end: '2017/07/10' },
        employee_name: @user1.chinese_name,
        sort_column: 'employee_name'
    }
    get training_absentees_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res['data'].all? do |row|
      TrainingAbsentee.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should export" do
    get "#{training_absentees_url}.xlsx"
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/xlsx', response.content_type
  end

  test "create" do
    post training_absentees_url, params: { training_absentee: {
        user_id: @user1.id,
        train_class_id: @train_class1.id,
        absence_reason: '缺席原因',
        submit_date: '2017/09/01 12:00',
    } }
    assert_response 200
    target = TrainingAbsentee.find(json_res['data']['id'])
    assert_equal @user1.id, target['user_id']
    assert_equal false, target['has_submitted_reason']
    assert_equal false, target['has_been_exempted']
    assert_equal @train_class1.id, target['train_class_id']
    assert_equal '缺席原因', target['absence_reason']
    assert_equal Time.zone.parse('2017/09/01 12:00'), target['submit_date']
  end

  test "show" do
    get training_absentee_url(102)
    assert_response 200
    assert_not_nil json_res['data']['user']
    assert_not_nil json_res['data']['train_class']
    assert_not_nil json_res['data']['train_class']['train']
    assert_not_nil json_res['data']['train_class']['title']
  end

  test "update 1.0" do
    # 未提交，员工提交跟进
    patch training_absentee_url(101), params: { training_absentee: { absence_reason: '缺席原因：公交没挤上，迟到了。' } }
    assert_response 200
    assert_equal true, TrainingAbsentee.find(101).has_submitted_reason
    assert_equal '缺席原因：公交没挤上，迟到了。', TrainingAbsentee.find(101).absence_reason
    assert_not_nil TrainingAbsentee.find(101).submit_date
  end

  test "update 2.0" do
    # 未提交，HR提交跟进
    patch training_absentee_url(101), params: { training_absentee: { has_been_exempted: true,
                                                                     absence_reason: 'HR跟进员工的缺席原因' } }
    assert_response 200
    assert_equal true, TrainingAbsentee.find(101).has_submitted_reason
    assert_not_nil TrainingAbsentee.find(101).submit_date
    assert_equal 'HR跟进员工的缺席原因', TrainingAbsentee.find(101).absence_reason
    assert_equal true, TrainingAbsentee.find(101).has_been_exempted
  end

  test "update 3.0" do
    # 已提交，HR修改跟进
    patch training_absentee_url(102), params: { training_absentee: { has_been_exempted: true,
                                                                     absence_reason: 'HR修改已提交跟进的缺席原因' } }
    assert_response 200
    assert_equal true, TrainingAbsentee.find(102).has_submitted_reason
    assert_equal 'HR修改已提交跟进的缺席原因', TrainingAbsentee.find(102).absence_reason
    assert_equal true, TrainingAbsentee.find(102).has_been_exempted
    assert_equal Time.zone.parse('2017/07/05 12:00'), TrainingAbsentee.find(102).submit_date
  end

end
