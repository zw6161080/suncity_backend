require 'test_helper'

class PositionsControllerTest < ActionDispatch::IntegrationTest
  test 'getting related postions with location_id' do
    3.times do
      create(:position_with_full_relations)
    end

    location = Location.first
    positions_count = location.positions.count

    get '/positions', params: {
      location_id: location.id,
      region: location.region_key
    }
    assert_response :ok
    assert_equal positions_count, json_res['data'].count
  end

  test 'getting related postions with location_id and department_id' do
    10.times do
      create(:position_with_full_relations)
    end
    3.times do
      create(:job_with_full_relations)
    end
    location = Location.first
    positions_count = location.positions.count
    get '/positions/position_with_department', params: {
        location_id: location.id,
        region: location.region_key,
        department_id: Job.first.department_id
    }
    assert_response :ok
  end
  test 'getting related postions with department_id' do
    3.times do
      create(:position_with_full_relations)
    end

    department = Department.first
    positions_count = department.positions.count

    get '/positions', params: {
      department_id: department.id,
      region: department.region_key
    }

    assert_response :ok
    assert_equal positions_count, json_res['data'].count
  end

  test 'get empty positions' do
    get '/positions', params: {
      region: 'macau'
    }
    assert_empty json_res['data']
  end

  test "create position" do

    current_user = create(:user)
    PositionsController.any_instance.stubs(:current_user).returns(current_user)
    PositionsController.any_instance.stubs(:authorize).returns(true)

    2.times do
      create(:location_with_sub_locations)
    end

    2.times do
      create(:department_with_locations)
    end

    select_location_ids = random_array_items(Location.all).map(&:id)
    select_department_ids = random_array_items(Department.all).map(&:id)

    params = {
      chinese_name: Faker::Company.position_name,
      english_name: 'Some Position',
      simple_chinese_name: 'asdf',
      region_key: 'macau',
      location_ids: select_location_ids,
      department_ids: select_department_ids,
      grade: 3,
      comment: 'some comment'
    }

    assert_difference('Position.count', 1) do
      post '/positions', params: params, as: :json
      assert_response :ok
    end

    first_position = Position.first
    assert_equal params[:region_key], first_position.region_key
    assert_equal select_location_ids.sort, first_position.location_ids.sort
    assert_equal select_department_ids.sort, first_position.department_ids.sort

    params = {
      chinese_name: Faker::Company.position_name,
      english_name: 'Position',
      simple_chinese_name: 'asdf',
      region_key: 'macau',
      parent_id: first_position.id,
      grade: 3,
      comment: 'some comment'
    }
    post '/positions', params: params, as: :json
    assert_response :ok
    assert_equal first_position.id, Position.last.parent_id
  end

  test 'update position' do
    current_user = create(:user)
    PositionsController.any_instance.stubs(:current_user).returns(current_user)
    PositionsController.any_instance.stubs(:authorize).returns(true)

    2.times do
      create(:position_with_full_relations)
    end

    params = {
      chinese_name: Faker::Company.department_name
    }

    position = Position.first

    patch "/positions/#{position.id}", params: params, as: :json

    assert_response :ok
    position.reload
    assert_equal "#{params[:chinese_name]} (#{position.number})", position.chinese_name

    params = {
      parent_id: Position.last.id
    }

    patch "/positions/#{position.id}", params: params, as: :json

    position.reload

    assert_equal params[:parent_id], position.parent_id
  end

  test 'show position' do
    position = create(:position_with_full_relations)
    get "/positions/#{position.id}"
    assert_response :ok
    assert_equal position.location_ids.sort, json_res['data']['location_ids'].sort
    assert_equal position.department_ids.sort, json_res['data']['department_ids'].sort
  end

  test 'get pisition tree view' do
    2.times do
      create(:position_with_full_relations)
    end

    tree = Position.to_tree
    assert_equal Position.roots.count, tree.count
    get "/positions/tree"
    assert_response :ok
    assert_equal tree.count, json_res['data'].count
  end

  test 'disable position' do
    current_user = create(:user)
    PositionsController.any_instance.stubs(:current_user).returns(current_user)
    PositionsController.any_instance.stubs(:authorize).returns(true)

    position = create(:position)
    assert position.enabled?

    patch "/positions/#{position.id}/disable"
    assert_response :ok
    position.reload
    assert position.disabled?
  end

  test 'open position' do
    position = create(:position)
    position.disabled!
    assert position.disabled?
    patch "/positions/#{position.id}/enable"
    assert_response :ok
    position.reload
    assert position.enabled?
  end

  test 'get position with position number' do
    3.times do
      create(:position_with_full_relations)
    end

    location = Location.first

    get '/positions', params: {
      region: location.region_key
    }

    fisrt_position_res = json_res['data'].first
    assert fisrt_position_res['chinese_name'].include?(fisrt_position_res['number'])
    assert fisrt_position_res['english_name'].include?(fisrt_position_res['number'])

  end
end
