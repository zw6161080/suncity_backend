require 'test_helper'

class SelectColumnTemplatesControllerTest < ActionDispatch::IntegrationTest
  test "获取可用字段模版测试" do
    params = {
      region: 'macau'
    }
    get '/select_column_templates/all_selectable_columns', params: params
    assert_response :ok
  end

  test "获取员工档案可用字段模版测试(with_section)" do
    params = {
        region: 'macau'
    }
    get '/select_column_templates/all_selectable_columns_with_section', params: params
    #assert json_res['data'].Array?
    assert json_res['data'].is_a? Array
    personal_information_is = 0
    position_information_is = 0
    i = 0
    while i < json_res['data'].length
      if personal_information_is == 0 && json_res['data'][i]['key'] == 'personal_information'
        personal_information_is = 1
      end
      if position_information_is == 0 && json_res['data'][i]['key'] == 'position_information'
        position_information_is = 1
      end
      i=i+1
    end
    assert_equal(1, personal_information_is)
    assert_equal(1, position_information_is)
    assert_response :ok
  end

  test "获取求职人档案可用字段模板(with_section)" do
    params = {
      region: 'macau'
    }
    get '/applicant_select_column_templates/all_selectable_columns_with_section', params: params
    assert_response :ok

    data = json_res['data']
    assert data.is_a? Array
    assert data.all? { |s| (["chinese_name", "english_name", "key", "fields"] - s.keys).empty? }
  end

  test "create select column template" do
    params = {
      region: 'macau'
    }

    get '/select_column_templates/all_selectable_columns', params: params

    template = json_res['data']
    select_columns = template.sample((1..template.length).to_a.sample).map{|field| field['key']}

    params = {
      region: 'macau',
      select_column_keys: select_columns,
      name: Faker::Name.name
    }

    assert_difference('SelectColumnTemplate.count', 1) do
      post '/select_column_templates', params: params, as: :json
    end

    assert SelectColumnTemplate.last.default
  end

  test "create select column template by department" do
    SelectColumnTemplatesController.any_instance.stubs(:current_user).returns(current_user)
    params = {
        region: 'macau'
    }

    get '/select_column_templates/all_selectable_columns', params: params

    template = json_res['data']
    select_columns = template.sample((1..template.length).to_a.sample).map{|field| field['key']}

    params = {
        region: 'macau',
        select_column_keys: select_columns,
        name: Faker::Name.name,
        department_id: 1
    }

    assert_difference('SelectColumnTemplate.count', 1) do
      post '/select_column_templates/create_by_department', params: params, as: :json
    end

    assert SelectColumnTemplate.last.default
  end

  test "get select column template" do
    template = create_select_column_template
    get "/select_column_templates/#{template.id}"
    assert_response :ok
    assert json_res['data'].key?('select_columns')
  end

  test "get select column template by department" do
    SelectColumnTemplatesController.any_instance.stubs(:current_user).returns(current_user)
    template = create_select_column_template
    get "/select_column_templates/index_by_department"
    assert_response :ok
  end

  test "edit select column template" do
    create_select_column_template

    template = SelectColumnTemplate.first
    all_fields = SelectColumnTemplate.all_selectable_columns(region: 'macau').as_json
    new_select_column_keys = all_fields.sample((1..all_fields.length).to_a.sample).map{|field| field['key']}

    params = {
      select_column_keys: new_select_column_keys,
      default: true
    }

    patch "/select_column_templates/#{template.id}", params: params, as: :json
    assert_response :ok
    template.reload
    assert_equal new_select_column_keys, template.select_column_keys
    assert template.default
  end

  test "delete a template" do
    template = create_select_column_template
    assert_difference('SelectColumnTemplate.count', -1) do
      delete "/select_column_templates/#{template.id}"
    end
  end

  test "get template list for a region" do
    region = 'macau'
    30.times do
      create_select_column_template
    end
    assert_equal 1, SelectColumnTemplate.where(default: true).count
    get '/select_column_templates', params: {
      region: region
    }

    assert_response :ok
    assert_equal 30, json_res['data'].length
    assert_equal 1, SelectColumnTemplate.where(default: true).count
    get '/select_column_templates', params: {
      region: 'manila'
    }

    assert_response :ok
    assert_equal 0, json_res['data'].length
  end
end
