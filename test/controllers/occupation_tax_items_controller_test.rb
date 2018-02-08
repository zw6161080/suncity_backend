require 'test_helper'

class OccupationTaxItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create(:department, id: 100, chinese_name: 'xxx', english_name: 'xxx')
    create(:department, id: 101, chinese_name: 'xxx1', english_name: 'xxx2')
    create(:department, id: 102, chinese_name: 'xxx1', english_name: 'xxx2')
    create(:position, id: 100, chinese_name: 'yyy', english_name: 'yyy')

    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:data, :OccupationTaxItem, :macau)
    @admin_role.add_permission_by_attribute(:data, :vp, :macau)
    test_user = create_test_user
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: test_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: test_user.location_id,
      position_id: 100,
      department_id: 100,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: test_user.id
    }
    test_ca = CareerRecord.create(params)
    @user = User.find(test_user.id)
    @user.empoid = 'test_empoid'
    @user.chinese_name = 'test_chinese_name'
    @user.english_name = 'test_english_name'
    @user.department_id = 100
    @user.position_id = 100
    @user.add_role(@admin_role)
    @user.save!

    OccupationTaxItem.generate(@user, Time.zone.parse('2017/01'))
    OccupationTaxItem.generate(@user, Time.zone.parse('2018/01'))

    OccupationTaxItemsController.any_instance.stubs(:current_user).returns(@user)

    @occupation_tax_item = create(:occupation_tax_item, user_id: @user.id, year: Time.zone.parse('2017/01'))
  end

  test "shoud update" do
    update_params = {
      comment: 'comment',
      quarter_1_tax_mop_after_adjust: '100',
      quarter_2_tax_mop_after_adjust: '100',
      quarter_3_tax_mop_after_adjust: '100'
    }
    patch update_comment_occupation_tax_item_url(@occupation_tax_item.id), params: update_params
    assert_response :success

    item = OccupationTaxItem.find(@occupation_tax_item.id)
    assert_equal item.comment, 'comment'
    assert_equal item.quarter_1_tax_mop_after_adjust, BigDecimal(100)
    assert_equal item.quarter_2_tax_mop_after_adjust, BigDecimal(100)
    assert_equal item.quarter_3_tax_mop_after_adjust, BigDecimal(100)

  end

  test "should get index" do
    get occupation_tax_items_url, as: :json
    assert_response :success
    assert json_res['data'].count > 0
    assert json_res['data'].all? do |row|
      OccupationTaxItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
    queries = {
      sort_column: :employee_id,
      sort_direction: :desc,
    year_month: '2017/01'
    }

    get occupation_tax_items_url(**queries), as: :json
    assert_response :success
    queries = {
      sort_column: :chinese_name,
      sort_direction: :desc
    }
    get occupation_tax_items_url(queries), as: :json
    assert_response :success


    queries = {
      sort_column: :department,
      sort_direction: :desc
    }
    get occupation_tax_items_url(queries), as: :json
    assert_response :success

    queries = {
      sort_column: :chinese_name,
      sort_direction: :desc
    }
    get occupation_tax_items_url(queries), as: :json
    assert_response :success

    queries = {
      sort_column: :chinese_name,
      sort_direction: :desc
    }
    get occupation_tax_items_url(queries), as: :json
    assert_response :success
    file = Rack::Test::UploadedFile.new('test/models/occupation_tax_items', 'application/xlsx')
    post import_occupation_tax_items_url, { file: file, year: '2017/01' }, as: :json
    assert_response :success
  end

  test "should export xlsx" do
    get "#{occupation_tax_items_url}.xlsx"
    assert_response :success
  end

  test "should get columns" do
    get columns_occupation_tax_items_url, as: :json
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
    get options_occupation_tax_items_url, as: :json
    assert_response :success
    OccupationTaxItem.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
  end

  test "should query data" do
    queries = {
      employee_id: @user.empoid,
      year: { begin: '2017/01', end: '2017/01' }
    }
    get occupation_tax_items_url(**queries), as: :json
    assert_response :success
    assert_equal 2, json_res['data'].count
    assert json_res['data'].all? do |row|
      OccupationTaxItem.statement_columns.map { |col| col['key'] }.include?(row['key'])
    end
  end

  test "should get year options" do
    get year_options_occupation_tax_items_url, as: :json
    assert_response :success
  end
end
