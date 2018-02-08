require 'test_helper'

class TrainRecordByTrainsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @template_type1 = create(:train_template_type, chinese_name: 'HR培訓',  english_name: 'HR Training',         simple_chinese_name: 'HR培训')
    @template_type2 = create(:train_template_type, chinese_name: '場面培訓', english_name: 'Scene Training',      simple_chinese_name: '现场培训')
    @template_type3 = create(:train_template_type, chinese_name: '賬房培訓', english_name: 'Accountant Training', simple_chinese_name: '账房培训')

    @template1 = create(:train_template, train_template_type_id: @template_type1.id)
    @template2 = create(:train_template, train_template_type_id: @template_type2.id)
    @template3 = create(:train_template, train_template_type_id: @template_type3.id)

    @train1 = create(:train, train_template_id: @template1.id, chinese_name: '電話服務培訓', english_name: 'Telephone service training', simple_chinese_name: '电话服务培训', train_number: '001',
                     train_date_begin: Time.zone.parse('2017/01/01'), train_date_end: Time.zone.parse('2017/01/03'), train_cost: '12500')

    @train2 = create(:train, train_template_id: @template2.id, chinese_name: '论文写作培訓', english_name: 'Thesis writingce training',  simple_chinese_name: '论文写作培訓', train_number: '002',
                     train_date_begin: Time.zone.parse('2017/01/07'), train_date_end: Time.zone.parse('2017/01/10'), train_cost: '10000')

    @train3 = create(:train, train_template_id: @template3.id, chinese_name: '甜品制作培訓', english_name: 'Sweetmeats training',        simple_chinese_name: '甜品制作培訓', train_number: '003',
                     train_date_begin: Time.zone.parse('2017/01/20'), train_date_end: Time.zone.parse('2017/01/20'), train_cost: '30000',)

    create(:train_record_by_train, train_id: @train1.id, final_list_count: 20, entry_list_count: 40, invited_count: 10, attendance_rate: '100.00', passing_rate: '100.00')
    create(:train_record_by_train, train_id: @train2.id, final_list_count: 95, entry_list_count: 120, invited_count: 5, attendance_rate:  '80.00', passing_rate:  '65.40')
    create(:train_record_by_train, train_id: @train3.id, final_list_count: 93, entry_list_count: 77, invited_count: 16, attendance_rate: '100.00', passing_rate:  '98.00')
    @train3.update(satisfaction_percentage: '80')

    TrainRecordByTrainsController.any_instance.stubs(:current_user).returns(create_test_user)
    TrainRecordByTrainsController.any_instance.stubs(:authorize).returns(true)

  end

  def test_index
    get train_record_by_trains_url
    assert_response :success
    byebug

    # 培訓名稱
    get train_record_by_trains_url, params: { train_id: [@train1.id, @train2.id] }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 培訓編號
    get train_record_by_trains_url, params: { train_number: '001' }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 培訓日期
    range = { begin: '2017/01/01', end: '2017/01/08' }
    get train_record_by_trains_url, params: { train_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: '2017/01/09', end: nil }
    get train_record_by_trains_url, params: { train_date: range }
    assert_response :success
    assert_equal 2, json_res['data'].count

    range = { begin: nil, end: '2017/01/02' }
    get train_record_by_trains_url, params: { train_date: range }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 培訓種類
    get train_record_by_trains_url, params: { train_type: [@template_type1.id, @template_type3.id] }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 培訓總費用
    get train_record_by_trains_url, params: { train_cost: '30000' }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 培訓人數
    get train_record_by_trains_url, params: { final_list_count: 20 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 培訓報名人數
    get train_record_by_trains_url, params: { entry_list_count: 120 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 培訓受邀人數
    get train_record_by_trains_url, params: { invited_count: 5 }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 課程出席率
    get train_record_by_trains_url, params: { attendance_rate: '100' }
    assert_response :success
    assert_equal 2, json_res['data'].count

    # 學員通過率
    get train_record_by_trains_url, params: { passing_rate: '100.00' }
    assert_response :success
    assert_equal 1, json_res['data'].count

    # 課程滿意度
    get train_record_by_trains_url, params: { satisfaction_degree: '80' }
    assert_response :success
    assert_equal 1, json_res['data'].count
  end

  def test_get_index_sorted
    sort_column = 'train_type'
    get train_record_by_trains_url, params: { sort_column: sort_column, sort_direction: :asc }
    assert_response :success
    ids1 = json_res['data'].pluck('id')

    get train_record_by_trains_url, params: { sort_column: sort_column, sort_direction: :desc }
    assert_response :success
    ids2 = json_res['data'].pluck('id')

    puts ids1.to_s
    puts ids2.to_s
  end

  def test_export
    get export_train_record_by_trains_url
    assert_response :success
    assert_equal 'Content-Disposition', response.headers['Access-Control-Expose-Headers']
    assert_equal 'application/xlsx', response.content_type
  end

  def test_columns
    get columns_train_record_by_trains_url
    assert_response :success
  end

  def test_options
    get options_train_record_by_trains_url
    assert_response :success
    assert_equal ['train_id', 'train_type'], json_res.keys
  end

  def test_create
    post train_record_by_trains_url, params: { train_record_by_train: { train_id: @train1.id } }
    assert_response 200
  end

end
