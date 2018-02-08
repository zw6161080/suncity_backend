require 'test_helper'

class LocationsControllerTest < ActionDispatch::IntegrationTest
  SUB_DEPARTMENTS_COUNT = 3
  setup do
    Department.any_instance.stubs(:recreate_bonus_element_settings).returns(nil)
    @location_a = create(:location)
    SUB_DEPARTMENTS_COUNT.times {
      @location_a.departments << create(:department)
    }
    @location_a.save
    LocationsController.any_instance.stubs(:authorize).returns(true)
  end

  test 'all_locations' do
    get all_locations_locations_url
    assert_response :ok
  end

  test 'index data with parent location' do
    create(:location, parent_id: 2)
    create(:location, id: 2)
    get '/locations'
    assert_response :ok
  end

  test 'getting related locations with position_id' do
    3.times do
      create(:position_with_full_relations)
    end

    position = Position.first
    locations_count = position.locations.count

    get '/locations', params: {
      position_id: position.id,
      region: position.region_key
    }

    assert_response :ok
    assert_equal locations_count, json_res['data'].count
  end

  test 'getting related locations with department_id' do
    3.times do
      create(:department_with_locations)
    end

    department = Department.first
    locations_count = department.locations.count

    get '/locations', params: {
      department_id: department.id,
      region: department.region_key
    }

    assert_response :ok
    assert_equal locations_count, json_res['data'].count
  end

  test 'get all locations information with departments' do
    get '/locations/with_departments'
    assert_response :success
    locations = json_res['data']
    assert locations.pluck('id').include?(@location_a.id)
    assert_equal SUB_DEPARTMENTS_COUNT, locations.find { |loc| loc['id'] == @location_a.id }['departments'].count
  end

 test 'creat localtion2' do
   location =create(:location)
   location.chinese_name ='bali1'
   location.english_name ='Location'
   location.region_key ='macau'
   location.save
   params = {
       chinese_name: 'bali1',
       english_name: 'Location',
       simple_chinese_name: 'bali1',
       region_key: 'macau'
   }
   post '/locations', params: params, as: :json

   assert_response 422

 end
  test 'create location' do
    params = {
      chinese_name: Faker::Company.location_name,
      english_name: 'Some Location',
      simple_chinese_name: 'sdf',
      region_key: 'macau'
    }
    assert_difference('Location.count', 1) do
      post '/locations', params: params, as: :json
      assert_response :ok
    end

    params = {
      chinese_name: Faker::Company.location_name,
      english_name: 'Location',
      simple_chinese_name: 'bali1',
      region_key: 'macau'
    }

    post '/locations', params: params, as: :json
    assert_response :ok
  end

  test 'edit location' do
    2.times do
      create(:location)
    end

    location = Location.first

    params = {
      chinese_name: Faker::Company.location_name
    }

    patch "/locations/#{location.id}", params: params, as: :json
    assert_response :ok
    location.reload

    assert_equal params[:chinese_name], location.chinese_name

    params = {
      parent_id: Location.last.id
    }

    patch "/locations/#{location.id}", params: params, as: :json

    location.reload

    assert_equal params[:parent_id], location.parent_id
  end

  test 'get location' do
    location = create(:location)

    get "/locations/#{location.id}"
    assert_response :ok
  end

  test 'get location tree view' do
    2.times do
      create(:location_with_sub_locations)
    end

    tree = Location.to_tree
    assert_equal 3, tree.count
    get "/locations/tree"
    assert_response :ok
    assert_equal tree.count, json_res['data'].count
  end

  test 'delete location' do
    create(:location)
    location = Location.first
    assert_difference('Location.count', -1) do
      delete "/locations/#{location.id}"
    end
  end

  test 'delete location error' do
    location =create(:location)
    location.id =1
    location.positions <<  create(:position)
    location.save
    delete "/locations/#{location.id}"
    assert_response 422
  end

  test 'get location_children' do
    location_1 = create(:location,chinese_name:"貴賓廳")
    location_2 = create(:location,chinese_name:"金沙")
    location_1.children << location_2
    create(:location,chinese_name:"辦公室")
    get '/locations/location_children'
    assert_response :success
  end

  test 'get location_children_with_parent' do
    location_1 = create(:location,chinese_name:"貴賓廳")
    location_2 = create(:location,chinese_name:"金沙")
    location_1.children << location_2
    create(:location,chinese_name:"辦公室")
    get '/locations/location_children_with_parent'
    assert_response :success
  end
end
