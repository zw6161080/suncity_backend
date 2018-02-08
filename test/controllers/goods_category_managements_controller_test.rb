require 'test_helper'

class GoodsCategoryManagementsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(:department, id: 9,   chinese_name: '行政及人力資源部')
    create(:position,   id: 39,  chinese_name: '網絡及系統副總監')

    create(:user, id: 100, grade: 1, department_id: 9, position_id: 39, chinese_name: '山姆', english_name: 'Sam')
    create(:user, id: 101, grade: 2, department_id: 9, position_id: 39, chinese_name: '莉莉', english_name: 'Lily')
    create(:user, id: 102, grade: 3, department_id: 9, position_id: 39, chinese_name: '阿汤哥', english_name: 'Tom')
    create(:user, id: 103, grade: 4, department_id: 9, position_id: 39, chinese_name: '杰克船长', english_name: 'Captain Jack')
    create(:user, id: 104, grade: 5, department_id: 9, position_id: 39, chinese_name: '小辣椒', english_name: 'Spicy')

    @goods1 = create(:goods_category_management, id: 1, chinese_name: '外套', english_name: 'Coat', simple_chinese_name: '外套', unit: '件', unit_price: 200, distributed_number: 20, collected_number: 10, unreturned_number: 10, creator_id: 100, create_date: '2016/05/01', can_be_delete: false )
    @goods2 = create(:goods_category_management, id: 2, chinese_name: '上衣', english_name: 'Shirt', simple_chinese_name: '上衣', unit: '件', unit_price: 180, distributed_number: 70, collected_number: 10, unreturned_number: 60, creator_id: 101, create_date: '2016/05/07', can_be_delete: false )
    @goods3 = create(:goods_category_management, id: 3, chinese_name: 'T恤', english_name: 'T-Shirt', simple_chinese_name: 'T恤', unit: '件', unit_price: 50, distributed_number: 300, collected_number: 0, unreturned_number: 300, creator_id: 101, create_date: '2016/05/07', can_be_delete: false )
    @goods4 = create(:goods_category_management, id: 4, chinese_name: '腰帶', english_name: 'Belt', simple_chinese_name: '腰帶', unit: '条', unit_price: 20, distributed_number: 120, collected_number: 120, unreturned_number: 0, creator_id: 102, create_date: '2016/01/07', can_be_delete: false )
    @goods5 = create(:goods_category_management, id: 5, chinese_name: '肩章', english_name: 'Shoulder board', simple_chinese_name: '肩章', unit: '对', unit_price: 10, distributed_number: 100, collected_number: 80, unreturned_number: 20, creator_id: 103, create_date: '2016/05/07', can_be_delete: false )
    @goods6 = create(:goods_category_management, id: 6, chinese_name: '彩旗', english_name: 'Coloured flags', simple_chinese_name: '彩旗', unit: '面', unit_price: 12, distributed_number: 0, collected_number: 0, unreturned_number: 0, creator_id: 104, create_date: '2017/01/01', can_be_delete: true )
    @goods7 = create(:goods_category_management, id: 7, chinese_name: '帽子', english_name: 'Hat', simple_chinese_name: '帽子', unit: '顶', unit_price: 23, distributed_number: 0, collected_number: 0, unreturned_number: 0, creator_id: 104, create_date: '2017/01/01', can_be_delete: true )

    GoodsCategoryManagementsController.any_instance.stubs(:current_user).returns(User.find(103))
  end

  test "should index" do
    get goods_category_managements_url
    assert_response :success
    json_res['data'].each do |record|
      assert_not_nil record['chinese_name']
      assert_not_nil record['english_name']
      assert_not_nil record['simple_chinese_name']
      assert_not_nil record['unit']
      assert_not_nil record['unit_price']
      assert_not_nil record['distributed_number']
      assert_not_nil record['collected_number']
      assert_not_nil record['unreturned_number']
      assert_not_nil record['create_date']
      assert_not_nil record['creator']
    end

    get goods_category_managements_url, params: { goods_name: '腰帶' }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get goods_category_managements_url, params: { unit: '件' }
    assert_response :success
    assert_equal 3, json_res['data'].count

    get goods_category_managements_url, params: { unit_price: 12 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get goods_category_managements_url, params: { distributed_number: 0 }
    assert_response :success
    assert_equal 2, json_res['data'].count

    get goods_category_managements_url, params: { collected_number: 0 }
    assert_response :success
    assert_equal 3, json_res['data'].count

    get goods_category_managements_url, params: { unreturned_number: 60 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    get goods_category_managements_url, params: { creator_id: 104 }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range_begin = '2016/01/01'
    range_end   = '2016/12/31'
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get goods_category_managements_url, params: { create_date: range }
    assert_response :success
    assert_equal 5, json_res['data'].count

    range_begin = '2016/01/01'
    range_end   = nil
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get goods_category_managements_url, params: { create_date: range }
    assert_response :success
    assert_equal 7, json_res['data'].count

    range_begin = nil
    range_end   = '2016/12/31'
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get goods_category_managements_url, params: { create_date: range }
    assert_response :success
    assert_equal 5, json_res['data'].count

    range_begin = '2016/01/01'
    range_end   = '2016/12/31'
    range = {}
    range[:begin] = range_begin
    range[:end]   = range_end
    get goods_category_managements_url, params: { create_date: range, collected_number: 10 }
    assert_response :success
    assert_equal 2, json_res['data'].count
  end

  test "should create" do
    create_params = {
        chinese_name: '雨衣',
        english_name: 'Raincoat',
        simple_chinese_name: '雨衣',
        unit: '件',
        unit_price: 600,
    }
    post goods_category_managements_url, params: { goods_category_management: create_params }, as: :json
    assert_response :success
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').id
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').english_name
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').simple_chinese_name
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').unit
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').unit_price
    assert_equal 0, GoodsCategoryManagement.find_by_chinese_name('雨衣').distributed_number
    assert_equal 0, GoodsCategoryManagement.find_by_chinese_name('雨衣').collected_number
    assert_equal 0, GoodsCategoryManagement.find_by_chinese_name('雨衣').unreturned_number
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').creator_id
    assert_not_nil GoodsCategoryManagement.find_by_chinese_name('雨衣').create_date
    assert_equal true, GoodsCategoryManagement.find_by_chinese_name('雨衣').can_be_delete
  end

  test "should show" do
    get goods_category_management_url(@goods1.id)
    assert_response :success
  end

  test "should update" do
    update_params = {
        chinese_name: '短裤',
        english_name: 'Shorts',
        simple_chinese_name: '短裤',
        unit: '条',
        unit_price: 300,
    }
    patch goods_category_management_url(@goods2.id), params: { goods_category_management: update_params }, as: :json
    assert_response 200
    assert_equal '短裤', GoodsCategoryManagement.find(@goods2.id).chinese_name
    assert_equal 'Shorts', GoodsCategoryManagement.find(@goods2.id).english_name
    assert_equal '短裤', GoodsCategoryManagement.find(@goods2.id).simple_chinese_name
    assert_equal '条', GoodsCategoryManagement.find(@goods2.id).unit
    assert_equal 300, GoodsCategoryManagement.find(@goods2.id).unit_price
  end

  test "should destroy" do
    assert_difference('GoodsCategoryManagement.count', -1) do
      delete goods_category_management_url(@goods7.id)
    end
    assert_response 204
  end

end
