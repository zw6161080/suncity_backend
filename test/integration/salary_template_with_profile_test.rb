require 'test_helper'

class SalaryTemplateWithProfileTest < ActionDispatch::IntegrationTest
  test '删除未使用的模板' do
    new_template = create_random_salary_template
    get "/salary_templates/#{new_template.id}/can_be_destroy"
    assert_equal true, json_res['data']
    delete "/salary_templates/#{new_template.id}"
    assert_response :ok
    assert_equal 0, SalaryTemplate.count
  end
  test '删除正被使用的模板' do
    res =  create_profile_with_welfare_and_salary_template
    get "/salary_templates/#{SalaryTemplate.first.id}/can_be_destroy"
    assert_equal false, json_res['data']
    delete "/salary_templates/#{SalaryTemplate.first.id}"
    assert_response :ok
    assert_equal 1, SalaryTemplate.count
  end
end
