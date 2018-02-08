require 'test_helper'

class GoodsCategoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(100)
    create_test_user(101)
    create_test_user(102)
    @current_user = create_test_user(103)
    create_test_user(104)

    @goods1 = create(:goods_category, id: 1, chinese_name: '外套', english_name: 'Coat', simple_chinese_name: '外套',           unit: '件', price_mop: 200, distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 100, created_at: '2016/05/01' )
    @goods2 = create(:goods_category, id: 2, chinese_name: '上衣', english_name: 'Shirt', simple_chinese_name: '上衣',          unit: '件', price_mop: 180, distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 101, created_at: '2016/05/07' )
    @goods3 = create(:goods_category, id: 3, chinese_name: 'T恤', english_name: 'T-Shirt', simple_chinese_name: 'T恤',          unit: '件', price_mop: 50, distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 101, created_at: '2016/05/07' )
    @goods4 = create(:goods_category, id: 4, chinese_name: '腰帶', english_name: 'Belt', simple_chinese_name: '腰帶',           unit: '条', price_mop: 20,  distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 102, created_at: '2016/01/07' )
    @goods5 = create(:goods_category, id: 5, chinese_name: '肩章', english_name: 'Shoulder board', simple_chinese_name: '肩章', unit: '对', price_mop: 10,  distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 103, created_at: '2016/05/07' )
    @goods6 = create(:goods_category, id: 6, chinese_name: '彩旗', english_name: 'Coloured flags', simple_chinese_name: '彩旗', unit: '面', price_mop: 12,  distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 104, created_at: '2017/01/01' )
    @goods7 = create(:goods_category, id: 7, chinese_name: '帽子', english_name: 'Hat', simple_chinese_name: '帽子',            unit: '顶', price_mop: 23,  distributed_count: 0, returned_count: 0, unreturned_count: 0, user_id: 104, created_at: '2017/01/01' )

    @sign1 = create(:goods_signing, id: 1, distribution_date: '2017/01/01', goods_status: 'not_sign', user_id: 100,           goods_category_id: 1, distribution_count: 2, distribution_total_value: 400, sign_date: nil, return_date: nil, distributor_id: 103, remarks: 'xxx' )
    @sign2 = create(:goods_signing, id: 2, distribution_date: '2017/01/03', goods_status: 'employee_sign', user_id: 101,      goods_category_id: 2, distribution_count: 2, distribution_total_value: 360, sign_date: '2017/01/05', return_date: nil, distributor_id: 103, remarks: 'xxx' )
    @sign3 = create(:goods_signing, id: 3, distribution_date: '2017/01/04', goods_status: 'returned', user_id: 102,           goods_category_id: 3, distribution_count: 1, distribution_total_value: 50, sign_date: '2017/01/05', return_date: '2017/01/15', distributor_id: 102, remarks: 'xxx' )
    @sign4 = create(:goods_signing, id: 4, distribution_date: '2017/01/04', goods_status: 'automatic_sign', user_id: 102,     goods_category_id: 4, distribution_count: 3, distribution_total_value: 50, sign_date: '2017/01/05', return_date: '2017/01/15', distributor_id: 102, remarks: 'xxx' )
    @sign5 = create(:goods_signing, id: 5, distribution_date: '2017/01/04', goods_status: 'no_return_required', user_id: 103, goods_category_id: 5, distribution_count: 3, distribution_total_value: 50, sign_date: '2017/01/05', return_date: '2017/01/15', distributor_id: 102, remarks: 'xxx' )
    @sign6 = create(:goods_signing, id: 6, distribution_date: '2017/01/04', goods_status: 'automatic_sign', user_id: 104,     goods_category_id: 4, distribution_count: 3, distribution_total_value: 50, sign_date: '2017/01/05', return_date: '2017/01/15', distributor_id: 102, remarks: 'xxx' )
    @sign7 = create(:goods_signing, id: 7, distribution_date: '2017/01/04', goods_status: 'automatic_sign', user_id: 103,     goods_category_id: 5, distribution_count: 3, distribution_total_value: 50, sign_date: '2017/01/05', return_date: '2017/01/15', distributor_id: 102, remarks: 'xxx' )

    GoodsCategory.all.each do |record|
      record.distributed_count = GoodsSigning
                                             .all
                                             .where(goods_category_id: record.id)
                                             .sum(:distribution_count)
      record.returned_count    = GoodsSigning
                                             .all
                                             .where(goods_category_id: record.id)
                                             .where(goods_status: 'returned')
                                             .sum(:distribution_count)
      record.unreturned_count  = GoodsSigning.all.where(goods_category_id: record.id).where(goods_status: 'not_sign').sum(:distribution_count) +
                                 GoodsSigning.all.where(goods_category_id: record.id).where(goods_status: 'employee_sign').sum(:distribution_count) +
                                 GoodsSigning.all.where(goods_category_id: record.id).where(goods_status: 'automatic_sign').sum(:distribution_count)
      record.save!
    end
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :goods_signing, :macau)
    @current_user.add_role(@admin_role)
    GoodsCategoriesController.any_instance.stubs(:current_user).returns(@current_user)
  end

  test "should get index" do
    # get goods_categories_url, as: :json
    get "#{goods_categories_url}.json", params: { sort_column: 'distributed_count', sort_direction: :asc }
    assert_response :success
    assert_equal [0, 0, 1, 2, 2, 6, 6], json_res['data'].pluck('distributed_count')
    data = json_res['data']
    assert data.count > 0
    assert data.all? do |row|
      GoodsCategory.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "get index sorted" do
    sort_column = 'employee_name'
    get "#{goods_categories_url}.json", params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get "#{goods_categories_url}.json", params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  test "should get columns" do
    get columns_goods_categories_url
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
    get options_goods_categories_url
    assert_response :success
    GoodsCategory.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
      # unit: ['件','条'],
      # goods_name: @goods1.chinese_name,
      employee_name: User.find(100).english_name,
      # created_at: { begin: @goods1.created_at.beginning_of_month.strftime('%Y/%m/%d') , end: @goods1.created_at.end_of_month.strftime('%Y/%m/%d') }
    }
    get goods_categories_url(**queries), as: :json
    assert_response :success
    assert_equal 1, json_res['data'].count
    assert json_res['data'].all? do |row|
      GoodsCategory.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should create goods_category" do
    assert_difference('GoodsCategory.count') do
      post goods_categories_url, params: { goods_category: {
          chinese_name: '雨衣',
          english_name: 'Raincoat',
          simple_chinese_name: '雨衣',
          unit: '件',
          price_mop: 600,
      } }, as: :json
    end
    assert_response :success
  end

  test "should show goods_category" do
    get goods_category_url(@goods1.id)
    assert_response :success
  end

  test "should update 1.0" do
    # 全改，不重复
    patch goods_category_url(@goods2.id), params: { goods_category: {
        chinese_name: '短裤',
        english_name: 'Shorts',
        simple_chinese_name: '短裤',
        unit: '条',
        price_mop: 300,
    } }, as: :json
    assert_response 200
    assert_equal '短裤', GoodsCategory.find(@goods2.id).chinese_name
    assert_equal 'Shorts', GoodsCategory.find(@goods2.id).english_name
    assert_equal '短裤', GoodsCategory.find(@goods2.id).simple_chinese_name
    assert_equal '条', GoodsCategory.find(@goods2.id).unit
    assert_equal 300, GoodsCategory.find(@goods2.id).price_mop
  end

  test "should update 2.0" do
    # 只改名字，名字无重复
    patch goods_category_url(@goods2.id), params: { goods_category: {
        chinese_name: '条纹上衣',
        english_name: 'Line Shirt',
        simple_chinese_name: 'TW上衣',
        unit: '件',
        price_mop: 180,
    } }, as: :json
    assert_response 200
    assert_equal '条纹上衣', GoodsCategory.find(@goods2.id).chinese_name
    assert_equal 'Line Shirt', GoodsCategory.find(@goods2.id).english_name
    assert_equal 'TW上衣', GoodsCategory.find(@goods2.id).simple_chinese_name
    assert_equal '件', GoodsCategory.find(@goods2.id).unit
    assert_equal 180, GoodsCategory.find(@goods2.id).price_mop
  end

  test "should update 3.0" do
    # 只改繁体中文名
    patch goods_category_url(@goods2.id), params: { goods_category: {
        chinese_name: '外套', # 外套 名字已经被占用
        english_name: 'Shirt',
        simple_chinese_name: '上衣',
        unit: '件',
        price_mop: 180,
    } }, as: :json
    assert_response 200
    assert_equal [], json_res['data']
    assert_equal '上衣', GoodsCategory.find(@goods2.id).chinese_name
    assert_equal 'Shirt', GoodsCategory.find(@goods2.id).english_name
    assert_equal '上衣', GoodsCategory.find(@goods2.id).simple_chinese_name
    assert_equal '件', GoodsCategory.find(@goods2.id).unit
    assert_equal 180, GoodsCategory.find(@goods2.id).price_mop
  end

  test "should update 4.0" do
    # 只改繁体中文名
    patch goods_category_url(@goods2.id), params: { goods_category: {
        chinese_name: '条纹上衣', # 名字未被占用
        english_name: 'Shirt',
        simple_chinese_name: '上衣',
        unit: '件',
        price_mop: 180,
    } }, as: :json
    assert_response 200
    assert_equal '条纹上衣', GoodsCategory.find(@goods2.id).chinese_name
    assert_equal 'Shirt', GoodsCategory.find(@goods2.id).english_name
    assert_equal '上衣', GoodsCategory.find(@goods2.id).simple_chinese_name
    assert_equal '件', GoodsCategory.find(@goods2.id).unit
    assert_equal 180, GoodsCategory.find(@goods2.id).price_mop
  end

  test "should update 5.0" do
    # 不改名字
    patch goods_category_url(@goods2.id), params: { goods_category: {
        chinese_name: '上衣',
        english_name: 'Shirt',
        simple_chinese_name: '上衣',
        unit: '条',
        price_mop: 300,
    } }, as: :json
    assert_response 200
    assert_equal '上衣', GoodsCategory.find(@goods2.id).chinese_name
    assert_equal 'Shirt', GoodsCategory.find(@goods2.id).english_name
    assert_equal '上衣', GoodsCategory.find(@goods2.id).simple_chinese_name
    assert_equal '条', GoodsCategory.find(@goods2.id).unit
    assert_equal 300, GoodsCategory.find(@goods2.id).price_mop
  end

  test "should destroy goods_category" do
    assert_difference('GoodsCategory.count', -1) do
      delete goods_category_url(@goods7.id)
    end
    assert_response 204
  end

  test "should get list" do
    get get_list_goods_categories_url
    assert_response :success
    json_res['data'].each do |record|
      assert_not_nil record['id']
      assert_not_nil record['chinese_name']
      assert_not_nil record['english_name']
      assert_not_nil record['simple_chinese_name']
    end
  end
end
