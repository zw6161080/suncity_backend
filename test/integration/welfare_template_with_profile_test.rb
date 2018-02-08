require 'test_helper'

class WelfareTemplateWithProfileTest < ActionDispatch::IntegrationTest
  test '删除未使用的模板' do
    new_template = create_random_welfare_template
    get "/welfare_templates/#{new_template.id}/can_be_destroy"
    assert_equal true, json_res['data']
    delete "/welfare_templates/#{new_template.id}"
    assert_response :ok
    assert_equal 0, WelfareTemplate.count
  end
  test '删除正被使用的模板' do
    res =  create_profile_with_welfare_and_salary_template
    byebug
    get "/welfare_templates/#{WelfareTemplate.first.id}/can_be_destroy"
    assert_equal false, json_res['data']
    delete "/welfare_templates/#{WelfareTemplate.first.id}"
    assert_response :ok
    assert_equal 1, WelfareTemplate.count
  end
end
