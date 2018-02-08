require 'test_helper'

class GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @department_1 = create(:department, chinese_name: '部门甲')
    @department_2 = create(:department, chinese_name: '部门乙')
    @department_3 = create(:department, chinese_name: '部门丁')
    @group = create(:group, chinese_name: '测试组', english_name: 'test group', simple_chinese_name: '测试组')
    @group_1 = create(:group, chinese_name: '测试组', english_name: 'test group', simple_chinese_name: '测试组')
    @group.departments << [@department_1, @department_2, @department_3]
    @group_1.departments << [@department_1, @department_2, @department_3]
    @group.save!
    @user = create(:user, department_id: @department_2.id, group_id: @group.id)
  end

  def test_index
    get groups_url, as: :json
    assert_response :success
    assert json_res['data'][0]['departments'].count, 3
    assert json_res['data'].count, 1
  end

  def test_create
    assert_difference('Group.count') do
      create_params = {
          chinese_name: '测试组2',
          english_name: 'group 2',
          simple_chinese_name: '测试组2',
          departments: [@department_1.id, @department_2.id]
      }
      post groups_url, params: create_params
    end
    assert_response :success
    assert_equal @department_1.groups.count, 3
    assert_equal @department_3.groups.count, 2
  end

  def test_update
    update_params = {
        chinese_name: '更改组名',
        english_name: 'changed name',
        simple_chinese_name: '更改组名',
        departments: [@department_2.id]
    }
    patch group_url(@group), params: update_params
    assert_response :success
    assert_equal json_res['update'], true

    update_params = {
        chinese_name: '更改组名',
        english_name: 'changed name',
        simple_chinese_name: '更改组名',
        departments: [@department_1.id]
    }
    patch group_url(@group), params: update_params
    assert_response :success
    assert_equal json_res['update'], false


  end

  def test_options_for_profile_create
    get options_for_profile_create_groups_url, params: {department_id: @department_1.id}
    assert_response :success
    assert_equal json_res['data'].count, @department_1.groups.count


  end

  def test_destroy
    assert_difference('Group.count', -1) do
      delete group_url(@group_1)
    end

    assert_response :success
  end
end
