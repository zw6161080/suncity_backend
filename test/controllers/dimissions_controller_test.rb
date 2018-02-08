require 'test_helper'

class DimissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    create_test_user(99)
    create_test_user(102)
    @current_user = create_test_user(100)
    @another_user =create_test_user(101)
    params = {
      career_begin: Time.zone.now.beginning_of_day,
      user_id: @current_user.id,
      deployment_type: 'entry',
      salary_calculation: 'do_not_adjust_the_salary',
      company_name: 'suncity_gaming_promotion_company_limited',
      location_id: create(:location).id,
      position_id: create(:position).id,
      department_id: create(:department).id,
      grade: 1,
      division_of_job: 'front_office',
      employment_status: 'informal_employees',
      inputer_id: @current_user.id,
      group_id: 1,
    }
    test_ca = CareerRecord.create(params)
    @another_user.chinese_name = @current_user.chinese_name
    @another_user.save
    @department = @current_user.department
    @position = @current_user.position
    @location = @current_user.location
    create(:attachment, id: 10000)
    create(:attachment, id: 10001)

    DimissionsController.any_instance.stubs(:current_user).returns(@current_user)
    @dimission = create(
      :dimission,
      is_compensation_year: true,
      is_in_blacklist: true,
      termination_is_reasonable: true,
      user_id: 100,
      apply_date: '2001/01/01',
      inform_date: '2001/02/01',
      last_work_date: '2003/03/01',
      dimission_type: 'termination',
      career_history_dimission_reason: 'job_description',
      creator_id: 101
    )
    create(:dimission,
           is_compensation_year: true,
           is_in_blacklist: true,
           termination_is_reasonable: true,
           user_id: @current_user.id,
           apply_date: '2010/05/05',
           inform_date: '2011/06/12',
           last_work_date: '2012/07/12',
           dimission_type: 'termination',
           career_history_dimission_reason: 'job_description',
           creator_id: 101)

    create(:dimission,
           is_compensation_year: true,
           is_in_blacklist: true,
           termination_is_reasonable: true,
           user_id: @another_user.id,
           apply_date: '2015/01/01',
           inform_date: '2015/02/01',
           last_work_date: '2015/03/01',
           dimission_type: 'termination',
           career_history_dimission_reason: 'job_description',
           creator_id: 102)
    DimissionsController.any_instance.stubs(:authorize).returns(true)
  end

  test "fetch apply options" do
    get apply_options_dimissions_url, as: :json
    assert_response :success
  end

  test "fetch field options" do
    get field_options_dimissions_url, as: :json
    assert_response :success
  end

  test "fetch termination compensation" do
    u = create_test_user(103)
    params = { user_id: u.id, is_reasonable_termination: false, last_work_date: '2017/08/01' }
    get termination_compensation_dimissions_url(**params), as: :json
    assert_response :success
  end

  test "should get index" do
    get dimissions_url, as: :json
    assert_response :success
    data = json_res
    assert data['data'].count > 0
    assert %w(data meta).all? { |field| data.key? field }
    assert data['data'].all? { |item|
      Dimission.column_names.all? { |field| item.key? field }
    }
    assert %w(total_count current_page total_pages).all? { |field| data['meta'].key? field }
  end

  test "should export xlsx" do
    get "#{dimissions_url}.xlsx", params: {locale: 'en-US'}
    assert_response :success
  end

  test "should query" do
    query_params = {
      apply_date_begin: '2001/01/01',
      apply_date_end: '2001/01/02',
      inform_date_begin: '2001/02/01',
      inform_date_end: '2001/02/02',
      last_work_date_begin: '2001/03/01',
      last_work_date_end: '2001/03/02',
      type: 'termination',
      employee_name: @current_user.chinese_name,
      employee_no: @current_user.empoid,
      location_id: @current_user.location_id,
      department_id: @current_user.department_id,
      position_id: @current_user.position_id,
      sort_column: 'employee_name',
      sort_direction: 'desc',
    }

    create(:dimission,

           is_compensation_year: true,
           is_in_blacklist: true,
           termination_is_reasonable: true,
           user_id: @current_user.id,
           apply_date: '2001/01/01',
           inform_date: '2001/02/01',
           last_work_date: '2001/03/01',
           dimission_type: 'termination',
           career_history_dimission_reason: 'job_description',
           creator_id: 101)

    create(:dimission,
           is_compensation_year: true,
           is_in_blacklist: true,
           termination_is_reasonable: true,
           user_id: @another_user.id,
           apply_date: '2001/01/01',
           inform_date: '2001/02/01',
           last_work_date: '2001/03/01',
           dimission_type: 'termination',
           career_history_dimission_reason: 'job_description',
           creator_id: 101)

    get dimissions_url(query_params), as: :json
    assert_response :success

    assert json_res['data'].count >= 0

    d = json_res['data']
    assert d.all? do |item|
      assert Date.parse(item['apply_date']) === Date.parse(query_params[:apply_date_begin])..Date.parse(query_params[:apply_date_end])
      assert Date.parse(item['inform_date']) === Date.parse(query_params[:inform_date_begin])..Date.parse(query_params[:inform_date_end])
      assert Date.parse(item['last_work_date']) === Date.parse(query_params[:last_work_date_begin])..Date.parse(query_params[:last_work_date_end])
      assert_equal item['termination_type'], query_params[:type]
      assert item['user']['chinese_name'] == query_params[:employee_name] || item['user']['english_name'] == query_params[:employee_name]
      assert_equal item['user']['empoid'], query_params[:employee_no]
      assert_equal item['user']['location_id'], query_params[:location_id]
      assert_equal item['user']['department_id'], query_params[:department_id]
      assert_equal item['user']['position_id'], query_params[:position_id]
    end

    (1...d.count).each do |i|
      assert d[i]['user']['chinese_name'] <= d[i - 1]['user']['chinese_name']
    end
  end

  test "should sort by column department etc" do
    ['department_id', 'location_id', 'position_id', 'employee_no'].each do |column_name|
      column_of_user = column_name
      if column_name == 'employee_no'
        column_of_user = 'empoid'
      end
      query_params = {
        sort_column: column_name,
        sort_direction: 'desc',
      }
      get dimissions_url(query_params), as: :json
      assert_response :success

      d = json_res['data']
      (1...d.count).each do |i|
        assert d[i]['user'][column_of_user] <= d[i - 1]['user'][column_of_user]
      end

      query_params = {
        sort_column: column_name,
        sort_direction: 'asc',
      }
      get dimissions_url(query_params), as: :json
      assert_response :success

      d = json_res['data']
      (1...d.count).each do |i|
        assert d[i]['user'][column_of_user] >= d[i - 1]['user'][column_of_user]
      end
    end
  end

  test "should create dimission" do
    dimission = {
      id: 999,
      created_at: DateTime.now,
      updated_at: DateTime.now,
      user_id: 100,
      apply_date: '2017/08/08',
      inform_date: '2017/09/09',
      last_work_date: '2018/10/09',
      final_work_date: '2017/09/08',
      is_in_blacklist: false,
      comment: 'test',
      last_salary_begin_date: '2017/09/09',
      last_salary_end_date: '2017/10/09',
      remaining_annual_holidays: 3,
      apply_comment: 'test comment',
      resignation_reason: ['reason_1', 'reason_2'],
      resignation_reason_extra: 'other reason',
      resignation_future_plan: ['plan 1', 'plan 2'],
      resignation_future_plan_extra: 'some other plan',
      resignation_certificate_languages: ['english', 'chinese'],
      resignation_is_inform_period_exempted: false,
      resignation_inform_period_penalty: 1000,
      resignation_is_recommanded_to_other_department: false,
      dimission_type: 'resignation',
      career_history_dimission_reason: 'others',
      reason_for_resignation_for_resignation_record: 'others',
      career_history_dimission_comment: 'test comment',
      comment_for_resignation_record: 'test-comment',
      is_compensation_year: true,
      termination_is_reasonable: true,
      notice_period_compensation: false
    }
    follow_ups = [
      {
        event_key: 'event_key_1',
        return_number: 3,
        compensation: '100.99',
        is_confirmed: true,
        handler_id: 99,
        is_checked: true,
      },
      {
        event_key: 'event_key_2',
        return_number: 4,
        compensation: '101.99',
        is_confirmed: true,
        handler_id: 100,
        is_checked: true,
      },
    ]
    approval_items = [
      {
        user_id: 101,
        datetime: DateTime.now,
        comment: 'test'
      },
      {
        user_id: 102,
        datetime: DateTime.now,
        comment: 'test 2'
      }
    ]
    attachment_items = [
      {
        file_name: 'test_file_name',
        comment: 'test comment',
        attachment_id: 10000,
      },
      {
        file_name: 'test_file_name_2',
        comment: 'test comment 2',
        attachment_id: 10001,
      }
    ]
    assert_difference('Dimission.count') do
      assert_difference -> { User.find(100).resignation_records.count }, 1 do
        create_params = dimission
                          .merge({ follow_ups: follow_ups })
                          .merge({ approval_items: approval_items })
                          .merge({ attachment_items: attachment_items })
        post dimissions_url, params: create_params, as: :json
      end
    end
    assert_response :success
    dimission_record = Dimission.find(json_res['data'])
    assert_equal dimission_record.resignation_reason, dimission[:resignation_reason]
    assert_not_nil dimission_record.user
    assert_not_nil dimission_record.creator
    assert_equal follow_ups.count, dimission_record.dimission_follow_ups.count
    assert_equal approval_items.count, dimission_record.approval_items.count
    assert_equal attachment_items.count, dimission_record.attachment_items.count

    get dimission_url(dimission_record), as: :json
    data = json_res['data']
    validate_dimission_data(data)
    assert_equal follow_ups.count, data['dimission_follow_ups'].count
    assert_equal approval_items.count, data['approval_items'].count
    assert_equal attachment_items.count, data['attachment_items'].count
  end

  test "should show dimission" do
    get dimission_url(@dimission), as: :json
    assert_response :success

    data = json_res['data']
    validate_dimission_data(data)
  end

  def validate_dimission_data(data)
    assert Dimission.column_names.all? { |field| data.key? field }
    assert_not data['id'] == nil
    assert_not_nil data['user']
    assert_not_nil data['creator']
    assert data['resignation_certificate_languages'].is_a?(Array)
    assert data['dimission_follow_ups'].is_a?(Array)
    assert data['approval_items'].is_a?(Array)
    assert data['attachment_items'].is_a?(Array)
    data['dimission_follow_ups'].each do |follow_up|
      assert_not_nil follow_up['handler']
    end
    data['approval_items'].each do |item|
      assert_not_nil item['user']
    end
    data['attachment_items'].each do |item|
      assert_not_nil item['creator']
    end
  end

end
