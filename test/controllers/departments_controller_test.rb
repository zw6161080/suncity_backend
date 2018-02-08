require 'test_helper'

class DepartmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    current_user = create(:user)
    DepartmentsController.any_instance.stubs(:current_user).returns(current_user)
    DepartmentsController.any_instance.stubs(:authorize).returns(true)
  end
  test 'with positions' do
    department = create(:department)
    department.positions << create(:position)
    get '/departments/with_positions'
    assert_response :ok
    byebug
  end

  test 'heads of department' do
    test_user = create_test_user
    create(:department, id: test_user.department_id)
    get '/departments'
    assert_response :ok
    assert_equal json_res['data'].first['heads'].first['id'], test_user.id
  end

  test 'head of each department' do
    create(:department, id: 2, head_id: current_user.id)
    get '/departments'
    assert_response :ok
  end

  test 'getting related departments with position_id' do
    3.times do
      create(:position_with_full_relations)
    end

    position = Position.first
    departments_count = position.departments.count

    get '/departments', params: {
      position_id: position.id,
      region: position.region_key
    }

    assert_response :ok
    assert_equal departments_count, json_res['data'].count
  end

  test 'getting related departments with position_id with pending' do
    3.times do
      create(:position_with_full_relations)
    end

    position = Position.first
    departments_count = position.departments.count

    get '/departments/index_with_Pending', params: {
        position_id: position.id,
        region: position.region_key
    }
    assert_response :ok
    assert_equal departments_count+1, json_res['data'].count
  end

  test 'getting related departments with location_id' do
    3.times do
      create(:department_with_locations)
    end

    location = Location.first
    departments_count = location.departments.count

    get '/departments', params: {
      location_id: location.id,
      region: location.region_key
    }

    assert_response :ok
    assert_equal departments_count, json_res['data'].count
  end

  test 'create department' do
    2.times do
      create(:location_with_sub_locations)
    end

    select_location_ids = Location.all.sample((1..Location.all.length).to_a.sample).map(&:id)
    params = {
      chinese_name: Faker::Company.department_name,
      english_name: 'Some Department',
      region_key: 'macau',
      location_ids: select_location_ids,
      comment: 'Some Comment'
    }

    assert_difference('Department.count', 1) do
      post '/departments', params: params, as: :json
      assert_response :ok
    end

    first_department = Department.first
    assert_equal select_location_ids.sort, first_department.location_ids.sort
    params = {
      chinese_name: Faker::Company.department_name,
      english_name: 'Department',
      region_key: 'macau',
      parent_id: first_department.id,
      comment: 'Some Comment',
    }

    post '/departments', params: params, as: :json
    assert_response :ok
    assert_equal first_department.id, Department.last.parent_id
  end

  test 'update department' do
    2.times do
      create(:department)
    end


    params = {
      chinese_name: Faker::Company.department_name
    }

    department = Department.first

    patch "/departments/#{department.id}", params: params, as: :json

    assert_response :ok
    department.reload
    assert_equal params[:chinese_name], department.chinese_name

    params = {
      parent_id: Department.last.id
    }

    patch "/departments/#{department.id}", params: params, as: :json

    department.reload

    assert_equal params[:parent_id], department.parent_id
  end

  test 'show department' do
    department = create(:department_with_locations)
    get "/departments/#{department.id}"
    assert_response :ok
    assert_equal department.location_ids.sort, json_res['data']['location_ids'].sort
  end

  test 'disable department' do
    department = create(:department)
    assert department.enabled?

    patch "/departments/#{department.id}/disable"
    assert_response :ok
    department.reload
    assert department.disabled?
  end

  test 'get department tree view' do
    2.times do
      create(:department_with_locations)
    end

    tree = Department.to_tree
    assert_equal Department.roots.count, tree.count

    get "/departments/tree"
    assert_response :ok
    assert_equal tree.count, json_res['data'].count
  end

  test 'open department' do
    department = create(:department)
    department.disabled!
    assert department.disabled?
    patch "/departments/#{department.id}/enable"
    assert_response :ok
    department.reload
    assert department.enabled?
  end

  test 'get profiles' do
    create_profile
    profile = Profile.last
    unless profile.user.department
      department = create(:department, id: profile.user.department_id)
    end
    department = profile.user.reload.department
      
    get "/departments/#{department.id}/profiles"
    assert_response :ok
    assert_equal profile.id, json_res['data']['profiles'].first.fetch("id")
  end

  test 'get positions' do
    department = create(:department)

    10.times do
      department.positions << create(:position)
    end

    get "/departments/#{department.id}/positions"
    
    assert_response :ok
    assert_equal json_res['data'].count, 10
  end
end
