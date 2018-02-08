require 'test_helper'

class ApplicantSelectColumnTemplatesControllerTest < ActionDispatch::IntegrationTest
  test "获取可用字段模版测试" do
    params = {
      region: 'macau'
    }

    get '/applicant_select_column_templates/all_selectable_columns', params: params
    assert_response :ok
  end

  test "create select column template" do
    params = {
      region: 'macau'
    }

    get '/applicant_select_column_templates/all_selectable_columns', params: params

    assert_not json_res['data'].map{|column| column['key']}.include?("basic_salary")

    template = json_res['data']
    select_columns = template.sample((1..template.length).to_a.sample).map{|field| field['key']}

    params = {
      region: 'macau',
      select_column_keys: select_columns,
      name: Faker::Name.name
    }

    assert_difference('ApplicantSelectColumnTemplate.count', 1) do
      post '/applicant_select_column_templates', params: params, as: :json
    end

    assert ApplicantSelectColumnTemplate.last.default
  end

  test "get select column template" do
    template = create_applicant_select_column_template
    get "/applicant_select_column_templates/#{template.id}"
    assert_response :ok
    assert json_res['data'].key?('select_columns')
  end

  test "edit select column template" do
    template = create_applicant_select_column_template

    all_fields = ApplicantSelectColumnTemplate.all_selectable_columns(region: 'macau').as_json
    new_select_column_keys = all_fields.sample((1..all_fields.length).to_a.sample).map{|field| field['key']}

    params = {
      select_column_keys: new_select_column_keys,
      default: true
    }

    patch "/applicant_select_column_templates/#{template.id}", params: params, as: :json
    assert_response :ok
    template.reload
    assert_equal new_select_column_keys, template.select_column_keys
    assert template.default
  end

  test "delete a template" do
    template = create_applicant_select_column_template
    assert_difference('ApplicantSelectColumnTemplate.count', -1) do
      delete "/applicant_select_column_templates/#{template.id}"
    end
  end

  test "get template list for a region" do
    region = 'macau'
    30.times do
      create_applicant_select_column_template
    end

    get '/applicant_select_column_templates', params: {
      region: region
    }

    assert_response :ok
    assert_equal 30, json_res['data'].length

    get '/applicant_select_column_templates', params: {
      region: 'manila'
    }

    assert_response :ok
    assert_equal 0, json_res['data'].length
  end
end
