require "test_helper"

class TrainingAbsenteesControllerTest < ActionDispatch::IntegrationTest
  setup do
    MedicalInsuranceParticipator.destroy_all
    LoveFund.destroy_all
    Profile.destroy_all
    TrainingAbsentee.destroy_all
    User.destroy_all
    create_test_user(100)
    create_test_user(101)
    @current_user = create_test_user

    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:information, :Train, :macau)
    @view_from_department_role = create(:role)
    @view_from_department_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    @view_from_department_role.add_permission_by_attribute(:manage, :train, :macau)
    @admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    @admin_role.add_permission_by_attribute(:manage, :train, :macau)
    @current_user.add_role(@admin_role)
    TrainsController.any_instance.stubs(:current_user).returns(@current_user )

    EntryListsController.any_instance.stubs(:current_user).returns(@current_user )
    seaweed_webmock
  end

  test 'create　train  and show ' do
    create(:position, id: 1)
    create(:department, id: 1)
    create(:location, id: 1)
    test_train_template_1 = create(:train_template, creator_id: @current_user.id, train_template_type_id: create(:train_template_type, id: 2).id)
    test_train_template_1.online_materials.create({
                                                      name: "string",
                                                      file_name: "string",
                                                      instruction: "string",
                                                      attachment_id: create(:attachment).id,
                                                      creator_id: @current_user.id
                                                  })
    test_train_template_1.attend_attachments.create({
                                                        file_name: "string",
                                                        attachment_id: create(:attachment).id,
                                                        creator_id: @current_user.id

                                                    })
    post trains_url, params: {
       train_template_id: test_train_template_1.id,
       chinese_name: 'string',
       english_name: 'string',
       simple_chinese_name: 'string',
       train_number: 'test1',
       train_date_begin: '2017/05/01',
       train_date_end: '2017/06/02',
       train_place: 'test2',
       train_cost: '2000',
       registration_date_begin: '2017/04/01',
       registration_date_end: '2017/05/02',
       registration_method: 'by_employee_and_department',
       limit_number: 20,
       locations: [@current_user.location.id],
       departments: [@current_user.department.id],
       positions: [@current_user.position.id],
       users_by_invite:[@current_user.id],
       titles: [{
           name: 'string',
           col: 1
                }],
       train_classes: [{
           time_end: 'string',
           time_begin: 'string',
           row: 1,
           col: 1,
                       }],
       grade: [@current_user.grade],
       division_of_job: [@current_user.profile.data['position_information']['field_values']['division_of_job']],
       comment: 'test3',
       train_template_chinese_name: "string",
       train_template_english_name: "string",
       train_template_simple_chinese_name: "string",
       course_number: "string",
       teaching_form: "string",
       train_template_type_id: create(:train_template_type).id,
       training_credits: 0,
       online_or_offline_training: "online_training",
       train_template_limit_number: 0,
       course_total_time: "10",
       course_total_count: "10",
       trainer: "string",
       language_of_training: "string",
       place_of_training: "string",
       contact_person_of_training: "string",
       course_series: "string",
       course_certificate: "string",
       introduction_of_trainee: "string",
       introduction_of_course: "string",
       goal_of_learning: "string",
       content_of_course: "string",
       goal_of_course: "string",
       assessment_method: "by_both",
       exam_format: "online",
       comprehensive_attendance_and_test_scores_not_less_than: 60,
       test_scores_percentage: 60,
       train_template_notice: "string",
       train_template_comment: "string",
       online_materials: [
         {
           name: "string",
           file_name: "string",
           instruction: "string",
           attachment_id: create(:attachment).id
         },
         {
           name: "string",
           file_name: "string",
           instruction: "string",
           attachment_id: create(:attachment).id
         }
       ],
       attend_attachments: [
         {
           attachment_id: create(:attachment).id,
           file_name: "string",
           comment: "string"
         }
       ]

    }
    assert_response :ok
    assert_equal EntryList.first.train_id, json_res['data']
    assert_equal json_res['data'], Train.first.id
    assert_equal Train.first.train_date_begin.to_date, Date.parse("2017/05/01")
    assert Train.first.grade.include? @current_user.grade
    assert_equal Train.first.titles.first.name, 'string'
    assert_equal Train.first.titles.first.train_classes.first.row, 1
    assert_equal Train.first.train_classes.first.row, 1

    assert_equal Train.first.positions.first.id , @current_user.position_id
    assert_equal Train.first.departments.first.id , @current_user.department_id
    assert_equal Train.first.locations.first.id , @current_user.location_id

    get introduction_train_url(Train.first)
    assert_response :ok

    get train_classes_train_url(Train.first)

    assert_response :ok
    assert_equal json_res['data'].first['title']['col'], 1
    assert_equal json_res['meta']['train_place'], Train.first.train_place
    assert_equal json_res['meta']['train_class_max_row'], 1

    get classes_train_url(Train.first)
    assert_response :ok
    assert_equal json_res['data']['train_classes'].first['title']['col'], 1

    get titles_train_url(Train.first)
    assert_response :ok
    assert_equal json_res['data'].first['col'], 1

    get online_materials_train_url(Train.first)
    assert_response :ok
    assert_equal json_res['data'].first['creator']['chinese_name'], @current_user.chinese_name


    patch train_url(Train.first), params: {
        chinese_name: 'string1'
    }
    assert_response :ok
    assert_equal Train.first.chinese_name, 'string1'

    user_test_1 = create_test_user

    patch train_url(Train.first), params: {
        positions: [user_test_1.position.id]
    }
    assert_response :ok
    assert_equal Train.first.chinese_name, 'string1'
    assert_equal Train.first.positions.first.id, user_test_1.position_id

    patch train_url(Train.first), params: {
        division_of_job: %w(front_office back_office)
    }
    assert_response :ok
    assert_equal Train.first.chinese_name, 'string1'
    assert_equal Train.first.positions.first.id, user_test_1.position_id
    assert_equal Train.first.division_of_job, %w(front_office back_office)

    patch train_url(Train.first), params: {
        titles: [{
                     name: 'string1',
                     col: 1
                 }],
        train_classes: [{
                            time_end: '2000/01/02 12:00:00',
                            time_begin: '2000/01/02 12:00:00',
                            row: 1,
                            col: 1,
                        }]
    }
    assert_response :ok
    assert_equal Train.first.chinese_name, 'string1'
    assert_equal Train.first.positions.first.id, user_test_1.position_id
    assert_equal Train.first.division_of_job, %w(front_office back_office)
    assert_equal Train.first.titles.first.name, 'string1'
    assert_equal Train.first.train_classes.first.row, 1
    assert_equal Train.first.train_classes.first.title.name, 'string1'
    assert_equal Train.first.train_classes.first.time_end.to_date.to_s, '2000-01-02'

    get trains_url, as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['status'], 'not_published'
    assert_equal json_res['data'][0]['chinese_name'], 'string1'
    assert_equal json_res['data'][0]['online_or_offline_training'], test_train_template_1.online_or_offline_training
    assert_equal json_res['data'][0]['train_template_type']['id'],  Train.order(created_at: :desc).first.train_template_type.id
    assert_equal json_res['meta']['not_published'], 1

    params = {
        query_method: 'by_mine'
    }

    get trains_url(params), as: :json
    assert_response :ok

    params = {
        query_method: 'by_department'
    }

    get trains_url(params), as: :json
    assert_response :ok

    params = {
        status: 'not_published'
    }

    get trains_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1
    params = {
        status: 'training'
    }

    get trains_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0
    params = {
        train_date_begin: '2017/05/01',
        train_date_end: '2017/06/02',
    }

    get trains_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1
    params = {
        train_date_begin: '2017/06/03'
    }

    get trains_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0
    params ={
        registration_method: 'by_employee_and_department'
    }
    get trains_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1
    assert_equal json_res['data'][0]['entry_lists_count'], 1
    assert_equal json_res['data'][0]['final_lists_count'], 0
    params = {
        registration_method: 'by_employee'
    }

    get trains_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0

    get options_trains_url
    assert_response :ok
    Train.statement_columns_base.each do |col|
      unless col['options_type'].nil?
        assert_not_nil json_res[col['key']]
      end
    end
    get field_options_trains_url
    assert_response :ok
    assert_equal json_res['data']['status']['options'][0]['key'], 'not_published'
  end


  test 'get options_for_create_train' do
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get options_for_create_train_trains_url
    assert_response :ok
    assert_equal json_res['data']['grades'].first['key'], 1
  end

  test 'get columns' do
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get columns_trains_url
    assert_response :ok
    assert json_res.count > 0
    assert json_res.all? do |col|
      client_attributes = Config
                              .get('report_column_client_attributes')
                              .fetch('attributes', [])
      assert col.keys.to_set.subset?(client_attributes.to_set)
    end
  end

  test "should get all_trains"do

    all_trains_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    Train.all.each{|item| item.update_columns(status: :completed) }
    get all_trains_trains_url, as: :json
    assert_response :success

    assert_equal json_res['data'][0]['empoid'], User.order(empoid: :desc).first.empoid
    assert_equal json_res['data'][0]['chinese_name'], User.order(empoid: :desc).first.chinese_name
    assert_equal json_res['data'][0]['english_name'], User.order(empoid: :desc).first.english_name
    assert_equal json_res['data'][0]['simple_chinese_name'], User.order(empoid: :desc).first.simple_chinese_name

    assert_equal json_res['data'][0]['department']['chinese_name'], User.order(empoid: :desc).first.department.chinese_name
    assert_equal json_res['data'][0]['department']['english_name'], User.order(empoid: :desc).first.department.english_name
    assert_equal json_res['data'][0]['department']['simple_chinese_name'], User.order(empoid: :desc).first.department.simple_chinese_name

    assert_equal json_res['data'][0]['position']['chinese_name'], User.order(empoid: :desc).first.position.raw_chinese_name
    assert_equal json_res['data'][0]['position']['english_name'], User.order(empoid: :desc).first.position.raw_english_name
    assert_equal json_res['data'][0]['position']['simple_chinese_name'], User.order(empoid: :desc).first.position.raw_simple_chinese_name

    assert_equal json_res['data'][0]['profile']['data']['position_information']['field_values']['date_of_employment'], User.order(empoid: :desc).first.profile.data['position_information']['field_values']['date_of_employment']
    if json_res['data'][0]['trains'][0]
      assert_equal json_res['data'][0]['trains'][0]['id'], User.order(empoid: :desc).first.trains.first.id
    end
    query_params = {
        empoid: @current_user.empoid,
        name: @current_user.chinese_name,
        department_id: @current_user.department_id,
        position_id: @current_user.position_id,
        date_of_employment_begin:@current_user.profile.data['position_information']['field_values']['date_of_employment'],
        date_of_employment_end:"2110/02/08",
        sort_column: 'empoid',
        sort_direction: 'desc',
    }
    get all_trains_trains_url(query_params), as: :json
    assert_response :success
    assert json_res['data'].count,1
    params = {
        locale: 'en',
        name: @current_user.english_name
    }
    get all_trains_trains_url(params), as: :json
    assert_response :success

    assert_equal json_res['data'].count , 1
  end

  test "all_trains_export_xlsx" do
    all_trains_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get "#{all_trains_trains_url}.xlsx"
    assert_response :success
  end

  test "fetch field_options_by_all_trains" do
    all_trains_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get field_options_by_all_trains_trains_url, as: :json
    assert_response :success
  end

  test "columns_by_all_trains" do
    all_trains_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get columns_by_all_trains_trains_url, as: :json
    assert_response :success
  end

  test "should get_user" do
    create(:position, id: 1)
    create(:department, id: 1)
    create(:location, id: 1)
    @current_user = User.find(100)
    @another_user = User.find(101)
    @current_user.add_role(@view_from_department_role)
    TrainsController.any_instance.stubs(:current_user).returns(@current_user)
    get get_user_trains_url, as: :json
    assert_response :success
    assert_equal json_res['data'][0]['empoid'], User.order(empoid: :desc).first.empoid
    query_params = {
        department_id: @current_user.department_id,
        position_id: @current_user.position_id,
        grade: @current_user.grade,
        division_of_job: @current_user.profile.data['position_information']['field_values']['division_of_job'],
        sort_column: 'empoid',
        sort_direction: 'desc',
    }
    get get_user_trains_url(query_params), as: :json
    assert_response :success
    assert json_res['data'].count > 0
  end

  test "fetch field_options_by_get_user" do
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get field_options_by_get_user_trains_url, as: :json
    assert_response :success
    assert json_res['data'].count > 0
  end

  test "fetch field_options_by_all_records" do
    all_records_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get field_options_by_all_records_trains_url,as: :json
    assert_response :success
  end

  test "should records_by_departments" do
    all_records_set_up
    records_by_departments_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get records_by_departments_trains_url,as: :json
    assert_response :success
  end

  test "records_by_departments_export_xlsx" do
    all_records_set_up
    records_by_departments_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get "#{records_by_departments_trains_url}.xlsx"
    assert_response :success
  end

  test "should get all_records" do
    all_records_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get all_records_trains_url,as: :json
    assert_response :success
    query_params = {
        empoid: "1",
        name: @train_record_1.chinese_name,
        department: @train_record_1.department_chinese_name,
        position: @train_record_1.position_chinese_name,
        train_result: @train_record_1.train_result,
        train_name: @train_1.id,
        train_number: @train_1.train_number,
        train_cost: @train_1.train_cost,
        attendance_rate: @train_record_1.attendance_rate,
        train_type: @train_template_1.train_template_type_id,
    }
    get all_records_trains_url(query_params),as: :json
    assert_response :success
    assert_equal json_res['data'].count , 1
    query_params = {
        attendance_rate: @train_record_1.attendance_rate,
    }
    get all_records_trains_url(query_params),as: :json
    assert_response :success
    assert_equal json_res['data'].count , 2
    query_params = {
        sort_column: 'train_name',
        sort_direction: 'desc',
    }
    get all_records_trains_url(query_params),as: :json
    assert json_res['data'][0]['train']['id'] > json_res['data'][1]['train']['id']
  end

  test "all_records_export_xlsx" do
    all_records_set_up
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get "#{all_records_trains_url}.xlsx"
    assert_response :success
  end

  test 'should get entry_lists_of_train' do
    train =  create_train
    EntryList.destroy_all
    post entry_lists_url, params: {
        user_id: @current_user.id,
        title_id: train.titles.first.id,
        operation: 'by_hr',
        train_id: train.id
    }
    assert_response :ok
    get entry_lists_train_url(train.id), as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['train_id'], train.id

    get "#{entry_lists_train_url(train.id)}.xlsx", as: :json
    assert_response :ok

    get entry_lists_field_options_train_url(train.id), as: :json
    assert_response :ok
    assert json_res.keys.count > 1

    get entry_lists_field_columns_train_url(train.id), as: :json
    assert_response :ok
    assert json_res.count > 1


    params = {
        id: train.id,
        empoid: @current_user.empoid
    }
    get entry_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1

    assert_equal json_res['meta']['total_count_in_all_titles'], 1
    assert_equal json_res['meta']['attend_count_in_all_titles'], 1


    params = {
        id: train.id,
        empoid: @current_user.empoid + '1'
    }

    get entry_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0


    params = {
        id: train.id,
        registration_time_begin: Time.zone.now.to_date.to_s,
        registration_time_end: Time.zone.now.to_date.to_s
    }

    get entry_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1
    params = {
        id: train.id,
        registration_time_begin: (Time.zone.now - 1.day).to_date.to_s,
        registration_time_end: (Time.zone.now - 1.day).to_date.to_s,
    }

    get entry_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0


    params = {
        id: train.id,
        department_id: @current_user.department_id
    }



    get entry_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1

    params = {
        id: train.id,
        department_id: @current_user.department_id + 1
    }

    get entry_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0


    test_user_1 = create_test_user
    params = [test_user_1.id]
    post entry_lists_train_url(train.id), params: params, as: :json
    assert_response :ok
    assert_equal train.entry_lists.count, 2


    get entry_lists_with_to_confirm_train_url(train.id), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1

    params = {
        id: train.id,
        sort_column: 'empoid',
        sort_direction: 'asc'
    }
    get entry_lists_with_to_confirm_train_url(params), as: :json
    assert_response :ok


  end


  test 'should get final_lists of train' do
    train =  create_train
    final_list =  FinalList.create(user_id: @current_user.id, train_id: train.id)
    final_list.train_classes << train.train_classes.first

    get "#{final_lists_train_url(train.id)}.xlsx", as: :json
    assert_response :ok

    get final_lists_field_options_train_url(train.id), as: :json
    assert_response :ok
    assert json_res.keys.count > 1

    get final_lists_field_columns_train_url(train.id), as: :json
    assert_response :ok
    assert json_res.count > 1

    params = {
        id: train.id
    }
    get final_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['train_id'], train.id
    assert_equal json_res['data'][0]['user_id'], @current_user.id
    assert_equal json_res['data'][0]['train_classes'][0]['id'], train.train_classes.first.id

    params = {
        id: train.id,
        empoid: @current_user.empoid
    }
    get final_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1

    params = {
        id: train.id,
        empoid: @current_user.empoid + '1'
    }
    get final_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0

  end

  test 'should get sign_lists of train' do
    train =  create_train
    sign_list = create(:sign_list, user_id: @current_user.id, train_id: train.id, train_class_id: train.train_classes.first.id)

    get "#{sign_lists_train_url(train.id)}.xlsx"
    assert_response :ok


    get sign_lists_field_options_train_url(train.id), as: :json

    assert_response :ok
    assert json_res.keys.count > 1

    get sign_lists_field_columns_train_url(train.id), as: :json
    assert_response :ok
    assert json_res.count > 1

    get sign_lists_train_url(train.id), as: :json
    assert_response :ok
    assert_equal json_res['data'][0]['user']['empoid'], @current_user.empoid
    assert_equal json_res['data'][0]['train_class']['title']['name'], train.train_classes.first.title.name
    params = {
        id: train.id,
        empoid: @current_user.empoid
    }

    get sign_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1

    params = {
        id: train.id,
        empoid: @current_user.empoid + '1'

    }

    get sign_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0

    params = {
        id: train.id,
        title_id: train.train_classes.first.title.id
    }

    get sign_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 1

    params = {
        id: train.id,
        title_id: train.train_classes.first.title.id + 1
    }
    get sign_lists_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 0
  end

  test 'should get entry_lists by department  and update' do
    MedicalInsuranceParticipator.destroy_all
    LoveFund.destroy_all
    Profile.where(user_id: [100,101]).destroy_all
    User.where(id: [100,101]).destroy_all
    TrainTemplate.destroy_all
    train =  create_train
    Department.find(1).trains << train
    test_user_1 = create_test_user
    test_user_2 = create_test_user

    post entry_lists_url, params: {
        user_id: test_user_1.id,
        title_id: train.titles.first.id,
        operation: 'by_hr',
        train_id: train.id
    }
    assert_response :ok
    params = {
        id: 1,
        train_id: train.id
    }

    get train_entry_lists_department_url(params)

    assert_response :ok
    if json_res['data'][-1]['title']
      assert_equal json_res['data'][-1]['title']['train_id'], train.id
    end
    assert_equal json_res['meta']['limit_number'], train.limit_number
    assert_equal json_res['meta']['titles'].first['col'], 1
    assert_equal json_res['meta']['titles'].first['total_count'], 2
    assert_equal json_res['meta']['titles'].first['department_count'],2
    assert_equal json_res['meta']['total_count_in_all_titles'], 2
    assert_equal json_res['meta']['department_count_in_all_titles'], 2

    params  =  [
        {
            id: test_user_1.id,
            registration_status: 'cancel_the_registration',
            change_reason: 'test3',
        }
    ]

    patch entry_lists_train_url(train.id), params: params, as: :json
    assert_response :ok
    assert_equal json_res['data']['update_tag'], 1
    assert_equal json_res['data']['create_tag'], 0
    assert_equal EntryList.last.change_reason, 'test3'
    assert_equal EntryList.last.registration_status, 'cancel_the_registration'

    params  =  [
        {
            id: test_user_1.id,
            registration_status: 'department_registration',
            title_id: train.titles.first.id,
            change_reason: 'test4',
        },
        {
            id: test_user_2.id,
            title_id: train.titles.first.id
        }
    ]
    patch entry_lists_train_url(train.id), params: params, as: :json
    assert_response :ok

    assert_equal json_res['data']['update_tag'], 1
    assert_equal json_res['data']['create_tag'], 1

    assert_equal EntryList.all[-2].change_reason, 'test3,test4'
    assert_equal EntryList.all[-2].registration_status, 'department_registration'
    assert_equal EntryList.last.change_reason, nil
    assert_equal EntryList.last.registration_status, 'department_registration'
  end

  test 'cancel train' do
    train = create_train
    patch cancel_train_url(train.id), as: :json
    assert_response :ok
    assert_equal Train.find(train.id).status, 'cancelled'
  end

  test 'get result and result_index' do
    train = create_train
    qt = create(:questionnaire_template)
    q = create(:questionnaire)
    q.questionnaire_template_id = qt['id']
    q.save
    q1 = create(:questionnaire, id: 2)
    q1.questionnaire_template_id = qt['id']
    q1.save
    user = @current_user
    test_user_1 =   create_test_user

    template_update_params = {
        region: 'macau',
        chinese_name: 'update 測試 1',
        english_name: 'update test 1',
        simple_chinese_name: 'update 测试 1',
        template_type: 'other',
        template_introduction: 'update template_introduction',
        creator_id: @current_user.id,
        comment: 'update test comment',

        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                is_required: true,
            },
        ],
        choice_questions: [
            {
                order_no: 2,
                question: 'choice question 2',
                is_multiple: true,
                is_required: false,
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        has_supplement: true,
                        supplement: 'supplement 1',
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        has_supplement: true,
                        supplement: 'supplement 2',
                    },
                    {
                        option_no: 3,
                        description: 'option 3',
                        has_supplement: false,
                        supplement: '',
                    },
                ],
            },
            {
                order_no: 5,
                question: 'choice question 5',
                is_multiple: false,
                is_required: true,
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        supplement: 'supplement 1',
                        attend_attachment: {
                            file_name: '1.jpg',
                            attachment_id: 1
                        },
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        supplement: 'supplement 2',
                        attend_attachment: {
                            file_name: '2.jpg',
                            attachment_id: 2
                        },
                    } ,
                ],
            },
        ],

        matrix_single_choice_questions: [
            {
                order_no: 1,
                title: 'matrix question 3',
                max_score: 10,
                matrix_single_choice_items: [
                    {
                        item_no: 1,
                        question: 'matrix question 1',
                        is_required: false,
                    },
                    {
                        item_no: 2,
                        question: 'matrix question 2',
                        is_required: true,
                    },
                    {
                        item_no: 3,
                        question: 'matrix question 3',
                        is_required: true,
                    },
                ],
            },
        ],
    }
    QuestionnaireTemplatesController.any_instance.stubs(:current_user).returns(create_test_user)
    QuestionnaireTemplatesController.any_instance.stubs(:authorize).returns(true)
    QuestionnairesController.any_instance.stubs(:current_user).returns(create_test_user)
    QuestionnairesController.any_instance.stubs(:authorize).returns(true)
    put "/questionnaire_templates/#{qt.id}", params: template_update_params, as: :json
    assert_response :ok
    update_params = {
        region: 'macau',
        questionnaire_template_id: qt['id'],
        user_id: user['id'],
        is_filled_in: true,
        release_date: '2017/06/20',
        release_user_id: user['id'],
        submit_date: '2017/06/23',
        comment: 'test comment',

        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                is_required: true,
                answer: 'answer 1',
            },
        ],
        choice_questions: [
            {
                order_no: 2,
                question: 'choice question 2',
                is_multiple: true,
                is_required: false,
                answer: [0, 1],
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        has_supplement: true,
                        supplement: 'supplement 1',
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        has_supplement: true,
                        supplement: 'supplement 2',
                    },
                    {
                        option_no: 3,
                        description: 'option 3',
                        has_supplement: false,
                        supplement: '',
                    },
                ],
            },
            {
                order_no: 5,
                question: 'choice question 5',
                is_multiple: false,
                is_required: true,
                answer: [2],
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        supplement: 'supplement 1',
                        attend_attachment: {
                            file_name: '1.jpg',
                            attachment_id: 1
                        },
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        supplement: 'supplement 2',
                        attend_attachment: {
                            file_name: '2.jpg',
                            attachment_id: 2
                        },
                    },
                ],
            },
        ],

        matrix_single_choice_questions: [
            {
                order_no: 1,
                title: 'matrix question 3',
                max_score: 10,
                matrix_single_choice_items: [
                    {
                        item_no: 1,
                        question: 'matrix question 1',
                        score: 5,
                        is_required: false,
                    },
                    {
                        item_no: 2,
                        question: 'matrix question 2',
                        score: 2,
                        is_required: true,
                    },
                    {
                        item_no: 3,
                        question: 'matrix question 3',
                        score: 9,
                        is_required: true,
                    },
                ],
            },
        ],
    }

    put "/questionnaires/#{q.id}", params: update_params, as: :json
    assert_response :ok
    update_params = {
        region: 'macau',
        questionnaire_template_id: qt['id'],
        user_id: test_user_1['id'],
        is_filled_in: true,
        release_date: '2017/06/20',
        release_user_id: test_user_1['id'],
        submit_date: '2017/06/23',
        comment: 'test comment',

        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                is_required: true,
                answer: 'answer 1',
            },
        ],
        choice_questions: [
            {
                order_no: 2,
                question: 'choice question 2',
                is_multiple: true,
                is_required: false,
                answer: [0, 1],
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        has_supplement: true,
                        supplement: 'supplement 1',
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        has_supplement: true,
                        supplement: 'supplement 2',
                    },
                    {
                        option_no: 3,
                        description: 'option 3',
                        has_supplement: false,
                        supplement: '',
                    },
                ],
            },
            {
                order_no: 5,
                question: 'choice question 5',
                is_multiple: false,
                is_required: true,
                answer: [2],
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        supplement: 'supplement 1',
                        attend_attachment: {
                            file_name: '1.jpg',
                            attachment_id: 1
                        },
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        supplement: 'supplement 2',
                        attend_attachment: {
                            file_name: '2.jpg',
                            attachment_id: 2
                        },
                    },
                ],
            },
        ],

        matrix_single_choice_questions: [
            {
                order_no: 1,
                title: 'matrix question 3',
                max_score: 10,
                matrix_single_choice_items: [
                    {
                        item_no: 1,
                        question: 'matrix question 1',
                        score: 5,
                        is_required: false,
                    },
                    {
                        item_no: 2,
                        question: 'matrix question 2',
                        score: 2,
                        is_required: true,
                    },
                    {
                        item_no: 3,
                        question: 'matrix question 3',
                        score: 9,
                        is_required: true,
                    },
                ],
            },
        ],
    }

    put "/questionnaires/#{q1.id}", params: update_params, as: :json
    assert_response :ok

    tp1 = create(:student_evaluation, train_id: train.id, user_id: @current_user.id)
    tp1.create_attend_questionnaire_template(questionnaire_template_id: qt.id)
    tp1.create_attend_questionnaire(questionnaire_id: q.id)
    tp2 = create(:student_evaluation, train_id: train.id, id: 2,  user_id: test_user_1.id)
    tp2.create_attend_questionnaire_template(questionnaire_template_id: qt.id)
    tp2.create_attend_questionnaire(questionnaire_id: q1.id)

    get result_train_url(train.id)
    assert_response :ok
    assert_equal json_res['data'].first['max_score'], 10
    assert_equal json_res['data'].first['matrix_single_choice_items'].first['item_no'], 1
    assert_equal json_res['data'].first['matrix_single_choice_items'].first['figure_result']['values'][4], '1.0'
    assert_equal json_res['data'].first['matrix_single_choice_items'].first['figure_result']['average_number'], '5.0'

    get result_index_train_url(train.id), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2

    params = {
        id: train.id,
        name: test_user_1.chinese_name
    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, User.where(chinese_name: test_user_1.chinese_name).count
    assert_equal json_res['data'][0]['questionnaire']['fill_in_the_blank_questions'][0]['answer'], 'answer 1'

    get result_index_field_options_train_url(train.id), as: :json

    assert_response :ok
    assert json_res.keys.count > 1


    get result_index_field_columns_train_url(train.id), as: :json
    assert_response :ok
    assert_equal json_res[9]['key'], '1.3'
    assert json_res.count > 1

    params = {
        id: train.id,
        position: [test_user_1.position_id]
    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2

    params = {
        id: train.id,
        '2': [0, 1]
    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2

    params = {
        id: train.id,
        '1.1': [5]
    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2

    params = {
        id: train.id,
        sort_column: 'name',
        sort_direction: 'desc'
    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2
    assert json_res['data'][0]['user']['chinese_name']  >      json_res['data'][1]['user']['chinese_name']


    params = {
        id: train.id,
        sort_column: 'empoid',
        sort_direction: 'desc'

    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2
    assert json_res['data'][0]['user']['empoid']  >      json_res['data'][1]['user']['empoid']
    params = {
        id: train.id,
        sort_column: '2',
        sort_direction: 'desc'

    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2
    params = {
        id: train.id,
        sort_column: '1.1',
        sort_direction: 'desc'

    }
    get result_index_train_url(params), as: :json
    assert_response :ok
    assert_equal json_res['data'].count, 2
    get "#{result_index_train_url}.xlsx", params: params
    assert_response :ok

  end

  test 'train index for all trains' do
    create_train
    TrainsController.any_instance.stubs(:authorize).returns(true)
    get trains_url + ".xlsx"
    assert_response :ok
  end

  test 'train update status' do
    train =  create_train
    assert_difference('MessageInfo.count') do
      patch has_been_published_train_url(train.id)
    end
    assert_response :ok
    assert_equal Train.find(train.id).status, 'registration_ends'
    patch training_train_url(train.id)
    assert_response :ok
    assert_equal Train.find(train.id).status, 'training'
    assert_difference('MessageInfo.count', 1) do
      patch cancelled_train_url({id:train.id, reason: 'test reason'})
    end
    assert_response :ok
    assert_equal Train.find(train.id).status, 'cancelled'

    create(:final_list, train_id: train.id, user_id: @current_user.id)
    assert_difference(['TrainRecord.count','TrainRecordByTrain.count'], 1) do
      patch completed_train_url(train.id)
      assert_response :ok
    end
    assert_equal Train.find(train.id).status, 'completed'
  end

  test 'train update result_evaluation' do
    train = create_train
    params = {
        id: train.id,
        satisfaction_percentage: 0.5
    }

    get result_evaluation_train_url(train.id)
    assert_response :ok
    assert_equal Train.find(train.id).satisfaction_percentage, nil

    assert_equal json_res['attend_count'], 0
    assert_equal json_res['evaluation_count'], 0
    assert_equal json_res['satisfaction_percentage'], nil

    patch update_result_evaluation_train_url(params)
    assert_response :ok
    assert_equal Train.find(train.id).satisfaction_percentage.to_s, '0.5'
  end

  test 'get trains_by_user' do
    train = create_train
    train.update(status: :completed)
    final_list = FinalList.create!(user_id: @current_user.id, train_id: train.id)

    @current_user.trains << train

    get trains_info_by_user_train_url(@current_user.id)
    assert_response 403

    @current_user.add_role(@admin_role)
    get trains_info_by_user_train_url(@current_user.id)
    assert_response :ok
    assert_equal json_res['passing_trainning_percentage'], '0.0'
    assert_equal json_res['is_can_be_absent'], true
    assert_equal json_res['training_attend_percentage'], "0.0"
    assert_equal json_res['trains'][0]['id'], train.id
    assert_equal json_res['trains'][0]['calcul_single_cost'], nil
    assert_equal json_res['trains'][0]['calcul_attend_percentage'], nil
    assert_equal json_res['trains'][0]['calcul_test_score'], nil
    assert_equal json_res['trains'][0]['calcul_train_result'], false
  end

  test 'create training_papars' do
    MedicalInsuranceParticipator.destroy_all
    LoveFund.destroy_all
    Profile.where(user_id: [100,101]).destroy_all
    User.where(id: [100,101]).destroy_all
    TrainTemplate.destroy_all
    qt = create(:questionnaire_template)
    template_update_params = {
        region: 'macau',
        chinese_name: 'update 測試 1',
        english_name: 'update test 1',
        simple_chinese_name: 'update 测试 1',
        template_type: 'other',
        template_introduction: 'update template_introduction',
        creator_id: @current_user.id,
        comment: 'update test comment',

        fill_in_the_blank_questions: [
            {
                order_no: 1,
                question: 'text question 1',
                is_required: true,
            },
        ],
        choice_questions: [
            {
                order_no: 2,
                question: 'choice question 2',
                is_multiple: true,
                is_required: false,
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        has_supplement: true,
                        supplement: 'supplement 1',
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        has_supplement: true,
                        supplement: 'supplement 2',
                    },
                    {
                        option_no: 3,
                        description: 'option 3',
                        has_supplement: false,
                        supplement: '',
                    },
                ],
            },
            {
                order_no: 5,
                question: 'choice question 5',
                is_multiple: false,
                is_required: true,
                options: [
                    {
                        option_no: 1,
                        description: 'option 1',
                        supplement: 'supplement 1',
                        attend_attachment: {
                            file_name: '1.jpg',
                            attachment_id: 1
                        },
                    },
                    {
                        option_no: 2,
                        description: 'option 2',
                        supplement: 'supplement 2',
                        attend_attachment: {
                            file_name: '2.jpg',
                            attachment_id: 2
                        },
                    },
                ],
            },
        ],

        matrix_single_choice_questions: [
            {
                order_no: 1,
                title: 'matrix question 3',
                max_score: 10,
                matrix_single_choice_items: [
                    {
                        item_no: 1,
                        question: 'matrix question 1',
                        is_required: false,
                    },
                    {
                        item_no: 2,
                        question: 'matrix question 2',
                        is_required: true,
                    },
                    {
                        item_no: 3,
                        question: 'matrix question 3',
                        is_required: true,
                    },
                ],
            },
        ],
    }
    put "/questionnaire_templates/#{qt.id}", params: template_update_params, as: :json
    train = create_train
    train.update(exam_template_id: qt.id)
    create(:final_list, train_id: train.id, user_id: @current_user.id)

    patch create_training_papers_train_url(train.id)
    assert_response :ok
    assert_equal @response.body, 'true'
    assert_equal TrainingPaper.last.user_id, @current_user.id

    patch create_student_evaluations_train_url({id: train.id, questionnaire_template_id: qt.id})
    assert_response :ok
    assert_equal @response.body, 'true'
    assert_equal StudentEvaluation.last.user_id, @current_user.id

    patch create_supervisor_assessment_train_url({id: train.id, questionnaire_template_id: qt.id} )
    assert_response :ok
    assert_equal @response.body, 'true'
    assert_equal SupervisorAssessment.last.user_id, @current_user.id

    assert_equal SupervisorAssessment.last.region, @current_user.profile.region

    get introduction_train_url(train.id)
    assert_response :ok
    assert_equal json_res['meta']['has_run_sa'], true

  end



  test 'get_training_absentees_status ' do

    get get_training_absentees_status_train_url(@current_user.id)
    assert_response :ok
    assert_equal @response.body, 'ok'
  end




  def all_trains_set_up
    create(:position, id: 1)
    create(:department, id: 1)
    create(:location, id: 1)
    @current_user = User.find(100)
    @another_user = User.find(101)
    @current_user.add_role(@view_from_department_role)
    TrainsController.any_instance.stubs(:current_user).returns(@current_user)
    @train_1 = create(:train,id: 1, train_template_id: 10, chinese_name: "train_1")
    @train_2 = create(:train,id: 2, train_template_id: 20, chinese_name: "train_2")
    @current_user.trains << @train_1
    @another_user.trains << @train_2
    @train_template_1 = create(:train_template,
                               id: 10,
                               chinese_name: "template_1",
                               english_name: "String",
                               simple_chinese_name: "String",
                               course_number: "001",
                               teaching_form: "Teacher1",
                               training_credits: 1,
                               online_or_offline_training: 1,
                               limit_number: 1,
                               course_total_time: 1,
                               course_total_count:1,
                               trainer: "String",
                               assessment_method: 1,
                               train_template_type_id: 10,
                               exam_format: 1,
                               exam_template_id: 1)
    @train_template_2 = create(:train_template,
                               id: 20,
                               chinese_name: "template_2",
                               english_name: "String",
                               simple_chinese_name: "String",
                               course_number: "002",
                               teaching_form: "Teacher2",
                               training_credits: 2,
                               online_or_offline_training: 1,
                               limit_number: 2,
                               course_total_time: 2,
                               course_total_count:2,
                               trainer: "String",
                               assessment_method: 1,
                               train_template_type_id: 20,
                               exam_format: 1,
                               exam_template_id: 1)
  end

  def all_records_set_up
    @train_record_1 = create(:train_record,
                             empoid: "1",
                             chinese_name: "员工1_hk",
                             english_name: "员工1_en",
                             simple_chinese_name: "员工1_cn",
                             department_chinese_name: "部门1_hk",
                             department_english_name: "部门1_en",
                             department_simple_chinese_name: "部门1_cn",
                             position_chinese_name: "职位1_hk",
                             position_english_name: "职位1_en",
                             position_simple_chinese_name: "职位1_cn",
                             train_result: true,
                             train_id: 10,
                             attendance_rate: 0.8)

    @train_record_2 = create(:train_record,
                             empoid: "2",
                             chinese_name: "员工2_hk",
                             english_name: "员工2_en",
                             simple_chinese_name: "员工2_cn",
                             department_chinese_name: "部门2_hk",
                             department_english_name: "部门2_en",
                             department_simple_chinese_name: "部门2_cn",
                             position_chinese_name: "职位2_hk",
                             position_english_name: "职位2_en",
                             position_simple_chinese_name: "职位2_cn",
                             train_result: false,
                             train_id: 20,
                             attendance_rate: 0.8)
    @train_1 = create(:train,id: 10, train_template_id: 10, chinese_name: "train_1", train_template_type_id: 10)
    @train_2 = create(:train,id: 20, train_template_id: 20, chinese_name: "train_2", train_template_type_id: 20)
    @train_template_1 = create(:train_template,
                               id: 10,
                               chinese_name: "template_1",
                               english_name: "String",
                               simple_chinese_name: "String",
                               course_number: "001",
                               teaching_form: "Teacher1",
                               training_credits: 1,
                               online_or_offline_training: 1,
                               limit_number: 1,
                               course_total_time: 1,
                               course_total_count:1,
                               trainer: "String",
                               assessment_method: 1,
                               train_template_type_id: 10,
                               exam_format: 1,
                               exam_template_id: 1)
    @train_template_2 = create(:train_template,
                               id: 20,
                               chinese_name: "template_2",
                               english_name: "String",
                               simple_chinese_name: "String",
                               course_number: "002",
                               teaching_form: "Teacher2",
                               training_credits: 2,
                               online_or_offline_training: 1,
                               limit_number: 2,
                               course_total_time: 2,
                               course_total_count:2,
                               trainer: "String",
                               assessment_method: 1,
                               train_template_type_id: 20,
                               exam_format: 1,
                               exam_template_id: 1)
    @train_template_type_1 = create(:train_template_type,
                                    id: 10,
                                    chinese_name: "类型1",
                                    created_at: "2017/01/01",
                                    updated_at: "2017/01/01")
    @train_template_type_2 = create(:train_template_type,
                                    id: 20,
                                    chinese_name: "类型2",
                                    created_at: "2017/01/01",
                                    updated_at: "2017/01/01")
  end

  def records_by_departments_set_up
    @train_record_3 = create(:train_record,
                             empoid: "3",
                             chinese_name: "员工3_hk",
                             english_name: "员工3_en",
                             simple_chinese_name: "员工3_cn",
                             department_chinese_name: "部门1_hk",
                             department_english_name: "部门1_en",
                             department_simple_chinese_name: "部门1_cn",
                             position_chinese_name: "职位3_hk",
                             position_english_name: "职位3_en",
                             position_simple_chinese_name: "职位3_cn",
                             train_result: false,
                             train_id: 30,
                             attendance_rate: 0.4)
    @train_3 = create(:train,id: 30, chinese_name: "train_3")
  end
end
