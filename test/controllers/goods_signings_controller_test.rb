require 'test_helper'

class GoodsSigningsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)
    @current_user = create_test_user(103)

    @goods1 = create(:goods_category, id: 1, chinese_name: '外套', english_name: 'Coat', simple_chinese_name: '外套', unit: '件', price_mop: 200, distributed_count: 20, returned_count: 10, unreturned_count: 10, user: User.find(100), created_at: '2016/05/01' )
    @goods2 = create(:goods_category, id: 2, chinese_name: '上衣', english_name: 'Shirt', simple_chinese_name: '上衣', unit: '件', price_mop: 180, distributed_count: 70, returned_count: 10, unreturned_count: 60, user: User.find(101), created_at: '2016/05/07' )
    @goods3 = create(:goods_category, id: 3, chinese_name: 'T恤', english_name: 'T-Shirt', simple_chinese_name: 'T恤', unit: '件', price_mop: 50, distributed_count: 300, returned_count: 0, unreturned_count: 300, user: User.find(101), created_at: '2016/05/07' )
    @goods4 = create(:goods_category, id: 4, chinese_name: '腰帶', english_name: 'Belt', simple_chinese_name: '腰帶', unit: '条', price_mop: 20, distributed_count: 120, returned_count: 120, unreturned_count: 0, user: User.find(102), created_at: '2016/01/07' )
    @goods5 = create(:goods_category, id: 5, chinese_name: '肩章', english_name: 'Shoulder board', simple_chinese_name: '肩章', unit: '对', price_mop: 10, distributed_count: 100, returned_count: 80, unreturned_count: 20, user: User.find(103), created_at: '2016/05/07' )
    @goods6 = create(:goods_category, id: 6, chinese_name: '彩旗', english_name: 'Coloured flags', simple_chinese_name: '彩旗', unit: '面', price_mop: 12, distributed_count: 0, returned_count: 0, unreturned_count: 0, user: User.find(100), created_at: '2017/01/01' )
    @goods7 = create(:goods_category, id: 7, chinese_name: '帽子', english_name: 'Hat', simple_chinese_name: '帽子', unit: '顶', price_mop: 23, distributed_count: 0, returned_count: 0, unreturned_count: 0, user: User.find(100), created_at: '2017/01/01' )
    @goods8 = create(:goods_category, id: 8, chinese_name: '啤酒', english_name: 'beer', simple_chinese_name: '啤酒', unit: '个', price_mop: 2, distributed_count: 0, returned_count: 0, unreturned_count: 0, user: User.find(100), created_at: '2017/01/01' )

    @sign1 = create(:goods_signing, id: 1, distribution_date: '2017/01/01', goods_status: 'not_sign', user_id: 100, goods_category_id: 1, distribution_count: 2, distribution_total_value: 400, sign_date: nil, return_date: nil, distributor_id: 103, remarks: 'xxx' )
    @sign2 = create(:goods_signing, id: 2, distribution_date: '2017/01/03', goods_status: 'employee_sign', user_id: 101, goods_category_id: 2, distribution_count: 3, distribution_total_value: 360, sign_date: '2017/01/05', return_date: nil, distributor_id: 103, remarks: 'xxx' )
    @sign3 = create(:goods_signing, id: 3, distribution_date: '2017/01/04', goods_status: 'returned', user_id: 102, goods_category_id: 3, distribution_count: 1, distribution_total_value: 50, sign_date: '2017/01/05', return_date: '2017/01/15', distributor_id: 102, remarks: 'xxx' )
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :goods_signing, :macau)
    @current_user.add_role(@admin_role)
    GoodsSigningsController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test "should get index" do
    get goods_signings_url, as: :json
    assert_response :success
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      GoodsSigning.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end

  end

  test "get index sorted" do
    sort_column = 'goods_category'
    get "#{goods_signings_url}.json", params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get "#{goods_signings_url}.json", params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  test "should get columns" do
    get columns_goods_signings_url
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
    get options_goods_signings_url
    assert_response :success
    GoodsSigning.statement_columns.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
        # goods_status: 'returned',
        goods_category: '外套',
        # department: User.find(100).department_id,
        # position: User.find(100).position_id,
        # distribution_count_with_unit: 1,
        # distribution_total_value: '50',
        # distributor: User.find(102).english_name,
        # career_entry_date: { begin: User.find(100).profile.data['position_information']['field_values']['date_of_employment'],
        #                      end: User.find(100).profile.data['position_information']['field_values']['date_of_employment'] }
    }
    get goods_signings_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res['data'].all? do |row|
      GoodsSigning.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should export" do
    get "#{goods_signings_url}.xlsx"
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/xlsx', response.content_type
  end

  test "should create" do
    create_params = {
        user_ids: [100,101,102],
        distributions: [
            {goods_category_id: 5, distribution_count: 1},
            {goods_category_id: 6, distribution_count: 2}
        ],
        remarks: '分发肩章、彩旗。'
    }
    post goods_signings_url, params: { goods_signing: create_params }, as: :json
    assert_response :success
    assert_equal 9, MessageInfo.count
    MessageInfo.all.each do |message|
      assert_equal 'notification', message['namespace']
      assert_not_nil message['targets']
      assert_not_nil message['content']
      assert_includes message['content'], "\"action\":\"distribution_notification\""
      assert_includes message['content'], 'distribution_count'
      assert_includes message['content'], 'goods_category'
    end
  end

  test "should show" do
    get goods_signing_url(@sign1)
    assert_response :success
  end

  test "should update" do
    update_params = {
        goods_category_id: 8,
        distribution_count: 10,
        goods_status: 'automatic_sign',
        sign_date: '2017/02/01',
        remarks: '自动签收'
    }
    patch goods_signing_url(@sign2), params: { goods_signing: update_params }, as: :json
    assert_response 200

    goods_signing = GoodsSigning.find(@sign2.id)
    goods_category = goods_signing.goods_category

    assert_equal goods_category.unreturned_count,10
    assert_equal goods_category.returned_count, 0
    assert_equal goods_category.distributed_count, 10

    update_params = {
      goods_category_id: 8,
      distribution_count: 10,
      goods_status: 'returned',
      sign_date: '2017/02/01',
      remarks: '自动签收'
    }
    patch goods_signing_url(@sign2), params: { goods_signing: update_params }, as: :json
    assert_response 200

    goods_signing = GoodsSigning.find(@sign2.id)
    goods_category = goods_signing.goods_category

    assert_equal goods_category.unreturned_count,0
    assert_equal goods_category.returned_count, 10
    assert_equal goods_category.distributed_count, 10


  end

  # test "should signing" do
  #   get signing_goods_signing_url(@sign1)
  #   assert_response :success
  #   MessageInfo.fourth do |message|
  #     assert_equal 'notification', message['namespace']
  #     assert_equal @sign1.user_id, message['targets'][0]
  #     assert_not_nil message['content']
  #     assert_includes message['content'], "\"action\":\"employee_signed\""
  #     assert_includes message['content'], 'employee'
  #     assert_includes message['content'], 'signed_count'
  #     assert_includes message['content'], 'goods_category'
  #   end
  # end

  test "auto_update_goods_status_notification" do
    GoodsSigning.new.instance_eval('GoodsSigning.auto_update_goods_status')
    assert_equal 'automatic_sign', GoodsSigning.find(1).goods_status
    assert_not_nil GoodsSigning.find(1).sign_date
    MessageInfo.fourth do |message|
      assert_equal 'notification', message['namespace']
      assert_equal response_test['user_id'], message['targets'][0]
      assert_not_nil message['content']
      assert_includes message['content'], "\"action\":\"automatic_signed\""
      assert_includes message['content'], 'distribution_count'
      assert_includes message['content'], 'goods_category'
    end
  end

end
