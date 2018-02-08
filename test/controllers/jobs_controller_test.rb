require 'test_helper'

class JobsControllerTest < ActionDispatch::IntegrationTest
  test 'get jobs list' do
    10.times do
      create(:job_with_full_relations)
    end

    5.times do
      create(:job_with_full_relations, region: 'manila')
    end

    region = 'macau'

    get '/jobs', params: { region: '' }

    assert_equal 0, json_res['data'].count

    get '/jobs', params: { region: 'manila' }
    assert_equal 5, json_res['data'].count

    get '/jobs', params: { region: 'macau' }
    assert_response :ok
    assert_equal 10, json_res['data'].count
    assert json_res['data'].first['key']
    assert json_res['data'].first['chinese_name']
    assert json_res['data'].first['english_name']

    get '/jobs', params: {
      department_id: Department.first.id,
      grade: 6,
      status: 'enabled',
      region: 'macau'
    }
    assert_response :ok
    assert_equal 1, json_res['data'].count
  end

  test 'get enabled jobs without pagination' do
    3.times do
      create(:job_with_full_relations, region: 'macau')
    end

    2.times do
      create(:job_with_full_relations, region: 'macau', status: 'disabled')
    end

    get '/jobs/enabled', params: {
      region: 'macau'
    }
    assert_response :ok
  end

  test "post create job" do

    current_user = create(:user)
    JobsController.any_instance.stubs(:current_user).returns(current_user)
    JobsController.any_instance.stubs(:authorize).returns(true)

    region = 'macau'
    department = create(:department)
    position = create(:position)

    params = {
      region: region,
      department_id: department.id,
      position_id: position.id,
      english_range: Faker::Lorem.sentence,
      number: 0
    }

    assert_difference('Job.count', 1) do
      post '/jobs', params: params, as: :json
      assert_response :ok
    end

    first_job = Job.first
    assert_equal department, first_job.department
    assert_equal position, first_job.position
    assert_equal region, first_job.region
    assert_equal "disabled", first_job.status
  end

  test 'patch update job' do

    current_user = create(:user)
    JobsController.any_instance.stubs(:current_user).returns(current_user)
    JobsController.any_instance.stubs(:authorize).returns(true)
    
    job = create(:job_with_full_relations)

    new_english_range = Faker::Lorem.sentence

    params = {
      english_range: new_english_range,
      number: 2
    }

    patch "/jobs/#{job.id}", params: params, as: :json

    assert_response :ok
    job.reload
    assert_equal new_english_range, job.english_range
    assert_equal "enabled", job.status
  end

  test 'get show job' do
    job = create(:job_with_full_relations)
    get "/jobs/#{job.id}"
    assert_response :ok

    assert_equal job.english_range, json_res['data']['english_range']
    assert_equal job.department_id, json_res['data']['department_id']
  end

  test "get jobs statuses" do
    get "/jobs/statuses"
    assert_equal json_res['data'], {"enabled"=>0, "disabled"=>1}
  end

  test "get jobs statistics" do
    5.times do
      create(:job, number: 3)
    end

    7.times do
      create_profile
    end

    region = 'macau'

    get '/jobs/statistics', params: { region: '' }
    data = {
      "jobs_count"=>0,
      "profiles_plan_count"=>0,
      "profiles_count"=>0,
      "need_count"=>0
    }

    assert_equal data, json_res['data']

    get '/jobs/statistics', params: { region: region }
    data = {
      "jobs_count"=>0,
      "profiles_plan_count"=>7,
      "profiles_count"=>7,
      "need_count"=>0
    }
    assert_equal data, json_res['data']

  end

  test '获取职位列表 包含待定' do
    5.times do
      create(:job)
    end

    get '/jobs/jobs_with_pending', params: { region: 'macau' }
    assert_response :ok
    assert_equal 6, json_res['data'].length
  end

end
