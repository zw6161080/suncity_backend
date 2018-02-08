# coding: utf-8
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'benchmark'
require 'webmock/minitest'
require_relative 'seaweed_webmock'
require 'mocha/mini_test'

class ActiveSupport::TestCase
  include FactoryGirl::Syntax::Methods
  include FormedProfileUpdatedParamsHelper

  include FormedProfileCreatedParamsHelper
  Faker::Config.locale = 'zh-CN'

  setup do
    # using_test_config
    Rails.cache.clear
    @random_string = [*('a'..'z'),*('0'..'9')].shuffle[0,8].join
    ActiveSupport::TestCase.any_instance.stubs(:current_user).returns(create(:user))
  end

  def get_test_response_content(endpoint)
    File.read(Rails.root.join(*%w(test fixtures files).append("#{endpoint}.txt")))
  end

  #def message_test_mock(user_id='some-user-id')
    def message_test_mock(user_id = 1)
    @user_id = user_id

    stub_request(:post, MessageService::request_url('/messages')).
        to_return(:status => 200, :body => {meta: [], data: []}.to_json)

    @merged_message_response = get_test_response_content('merged_message_response')
    @unread_message_response = get_test_response_content('unread_message_response')

    @unread_messages_count = get_test_response_content('unread_message_count')
    @read_message_response = get_test_response_content('read_message_response')

    stub_request(:get, MessageService::request_url("/users/#{@user_id}/merged_messages")).
        with(query: hash_including({namespace: Message::TASK_NAMESPACE})).
        to_return(status: 200, body: @merged_message_response, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, MessageService::request_url("/users/#{@user_id}/unread_messages")).
        with(query: hash_including({namespace: Message::TASK_NAMESPACE})).
        to_return(status: 200, body: @unread_message_response, headers: {'Content-Type' => 'application/json'})

    stub_request(:get, MessageService::request_url("/users/#{@user_id}/unread_messages_count")).
        with(query: hash_including({namespace: Message::TASK_NAMESPACE})).
        to_return(status: 200, body: @unread_messages_count, headers: {'Content-Type' => 'application/json'})

    stub_request(:post, MessageService::request_url('/messages/read')).
        to_return(:status => 200, :body => {meta: [], data: []}.to_json)

    stub_request(:post, MessageService::request_url('/messages/read_all')).
        to_return(:status => 200, :body => {meta: [], data: []}.to_json)
  end

  def json_res
    JSON.parse(@response.body)
  end

  def assert_error
    assert_equal 'error', json_res['state']
  end

  def create_profile
    profile = build(:profile)
    params = fill_profile_template(Profile.template(region: 'macau').as_json)
    profile.sections = Profile.fork_template(region: 'macau', params: params)
    profile.region = 'macau'
    profile.save
    profile
  end

  def create_applicant_profile
    applicant_profile = build(:applicant_profile)
    params = fill_profile_template(ApplicantProfile.template(region: 'macau').as_json)
    applicant_profile.sections = ApplicantProfile.fork_template(region: 'macau', params: params)
    applicant_profile.region = 'macau'
    applicant_profile.save
    applicant_profile
  end

  def create_select_column_template
    all_fields = SelectColumnTemplate.all_selectable_columns(region: 'macau').as_json
    selected_fields = all_fields.sample((1..all_fields.length).to_a.sample).map{|field| field['key']}
    SelectColumnTemplate.create({
      select_column_keys: selected_fields,
      name: Faker::Name.name,
      region: 'macau'
    })
  end

  def create_applicant_select_column_template
    all_fields = ApplicantSelectColumnTemplate.all_selectable_columns(region: 'macau').as_json
    selected_fields = all_fields.sample(all_fields.length).map{|field| field['key']}
    # selected_fields = all_fields.sample((1..all_fields.length).to_a.sample).map{|field| field['key']}
    ApplicantSelectColumnTemplate.create({
      select_column_keys: selected_fields,
      name: Faker::Name.name,
      region: 'macau'
    })
  end

  def using_test_config
    Config.set_config_path(File.join(Rails.root, 'test', 'fixtures', 'config'))
  end

  def random_value_of_field(field)
    case field['type']
    when 'date'
      Faker::Date.between(10.year.ago, Date.today).to_s.split('-').join('/')
    when 'image'
      Faker::Avatar.image
    else
      "#{field['chinese_name']}-#{@random_string}-#{(1..1000).to_a.sample}"
    end
  end

  def get_options_from_end_point(endpoint)
    case endpoint
    when '/users'
      [
        {
          'key' => 1,
          'chinese_name' => Faker::Name.name
        }
      ]
    when '/positions'
      [
        {
          'key' => 1,
          'chinese_name' => Faker::Company.position_name
        }
      ]
    when '/departments'
      [
        {
          'key' => 1,
          'chinese_name' => Faker::Company.department_name
        }
      ]
    when '/locations'
      [
        {
          'key' => 1,
          'chinese_name' => Faker::Company.location_name
        }
      ]
    when '/groups'
      [
        {
          'key' => nil,
          'chinese_name' => Faker::Company.group_name
        }
      ]
    when '/jobs/jobs_with_pending'
      3.times do
        create(:job_with_full_relations)
      end

      Job.all.as_json(methods: :key)
    end
  end

  def random_fill_field(field)
    field = field.clone
    if field['type'] == 'select' or field['type'] == 'radio'
      if field['select'].nil?
        field['value'] = nil
      else
        if field['select'].key?('type') and field['select']['type'] == 'api'
          field['value'] = get_options_from_end_point(field['select']['endpoint'])&.sample['key']
        else
          p field['select']['options'] if field['select']['options'].nil?
          field['value'] = field['select']['options'].sample['key']
        end
      end
    else
      field['value'] = random_value_of_field(field)
    end
    field
  end

  def random_fill_fields(fields)
    fields.map do |field|
      random_fill_field(field)
    end
  end

  def fill_profile_template(template)
    template.map{ |section|
      case section['type']
      when 'table'
        rows = []
        row_fields = random_fill_fields(section['schema']).map{|field|
          {
            'key' => field['key'],
            'value' => field['value'],
          }
        }.inject({}){|hash, field| hash[field['key']] = field['value']; hash}

        row = row_fields
        rows.push(row)
        section['rows'] = rows
      else
        fields = random_fill_fields(section['fields']).map{ |field|
          {
            'key' => field['key'],
            'value' => field['value'],
          }
        }.inject({}){|hash, field| hash[field['key']] = field['value']; hash}
        section['field_values'] = fields
      end
      section
    }.map{ |section|
      res = {}
      res['key'] = section['key']
      case section['type']
      when 'table'
        res['rows'] = section['rows']
      else
        res['field_values'] = section['field_values']
      end
      res
    }
  end

  def random_array_items(arr)
    arr.sample((1..arr.length).to_a.sample)
  end

  def rostered_roster
    roster = create(:roster)
    department = roster.department
    position = create(:position)
    department.positions << position

    create(:shift, roster_id: roster.id, chinese_name: '早班', english_name: 'am', start_time: '06:00', end_time: '12:00')
    create(:shift, roster_id: roster.id, chinese_name: '中班', english_name: 'pm', start_time: '12:00', end_time: '18:00')
    create(:shift, roster_id: roster.id, chinese_name: '晚班', english_name: 'night', start_time: '18:00', end_time: '24:00')

    10.times do
      department.employees << Profile.find(create_profile_with_welfare_and_salary_template(department.id, position.id)[:id]).user

    end

    roster.start_roster!
    roster.reload
  end

  def create_timesheet_date_with_roster(roster)
    roster.items.each do |item|
      if item.shift

      end
    end
  end

  def create_test_user(user_id = nil)
    region = 'macau'
    template = Profile.template(region: region).as_json
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)


    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    sections_hash = filled_template.as_json

    ret = nil
    ActiveRecord::Base.transaction do
      user = User.new
      user.id = user_id if user_id.present?
      user.password = '123456'
      user.save!

      the_profile = user.build_profile
      the_profile.sections = Profile.fork_template(region: 'macau', params: sections_hash)
      the_profile.is_stashed = false
      the_profile.save!

      ret = user
    end
    ret
  end
  #initial_department_id 初始部门id
  #initial_position_id 初始职位id
  #initial_location_id 初始场馆id
  def create_profile_with_welfare_and_salary_template(initial_department_id = nil, initial_position_id = nil, initial_location_id = nil)

    region = 'macau'
    template = Profile.template(region: region).as_json
    #随机填充Template中的数据
    filled_template = fill_profile_template(template)
    filled_template[1]['field_values']['empoid'] = Faker::Number.number(8)
    filled_template[4]['rows'][0].merge!({
                                             position_end_date: nil,
                                             deployment_type: 'entry',
                                             salary_calculation: 'do_not_adjust_the_salary',
                                             department: (initial_department_id || create(:department).id),
                                             position: (initial_position_id ||create(:position).id),
                                             location: (initial_location_id ||create(:location).id),
                                             deployment_instructions: nil,
                                             comment: nil
                                         })

    filled_template[6]['rows'][0].merge!({
                                             welfare_template_id: welfare_template.id,
                                             welfare_history_reason_for_change: '入职',
                                             comments: nil,
                                         })

    filled_template[5]['rows'][0].merge!({
                                             salary_template_id: salary_template.id,
                                             salary_history_reason_for_change: '入职',
                                             salary_history_comment: nil,
                                             hide_column:{
                                                 salary_unit: random_select_item_from_array(['mop','hkd']),
                                                 basic_salary: Random.new.rand(1000),
                                                 bonus: Random.new.rand(1000),
                                                 attendance_award: Random.new.rand(1000),
                                                 house_bonus: Random.new.rand(1000),
                                                 tea_bonus: Random.new.rand(1000),
                                                 kill_bonus: Random.new.rand(1000),
                                                 performance_bonus: Random.new.rand(1000),
                                                 charge_bonus: Random.new.rand(1000),
                                                 commission_bonus: Random.new.rand(1000),
                                                 receive_bonus: Random.new.rand(1000),
                                                 exchange_rate_bonus: Random.new.rand(1000),
                                                 guest_card_bonus: Random.new.rand(1000),
                                                 respect_bonus: Random.new.rand(1000),
                                             }
                                         })
    filled_template[5]['hide_column'] ||= {}

    filled_template[5]['hide_column'].merge!({
                                                 salary_unit: random_select_item_from_array(['mop','hkd']),
                                                 basic_salary: Random.new.rand(1000),
                                                 bonus: Random.new.rand(1000),
                                                 attendance_award: Random.new.rand(1000),
                                                 house_bonus: Random.new.rand(1000),
                                                 tea_bonus: Random.new.rand(1000),
                                                 kill_bonus: Random.new.rand(1000),
                                                 performance_bonus: Random.new.rand(1000),
                                                 charge_bonus: Random.new.rand(1000),
                                                 commission_bonus: Random.new.rand(1000),
                                                 receive_bonus: Random.new.rand(1000),
                                                 exchange_rate_bonus: Random.new.rand(1000),
                                                 guest_card_bonus: Random.new.rand(1000),
                                                 respect_bonus: Random.new.rand(1000),
                                             })
    #离职，暂借，辞职创建参数置空
    filled_template[7]['rows'] = []
    filled_template[8]['rows'] = []
    filled_template[9]['rows'] = []

    id_card_number = Faker::Name.id_card_number
    filled_template.find { |s| s['key'] == 'personal_information' }['field_values']['id_number'] = id_card_number
    sections = filled_template.as_json
    forked_template = Profile.fork_template(region: region, params: formed_sections(sections))
    ActiveRecord::Base.transaction do
      user = User.new
      user.password = TEST_PASSWORD if Object.const_defined?('TEST_PASSWORD')
      user.save!
      profile = user.build_profile
      profile.sections = forked_template
      profile.save!
      [{
           file_name: 'test file name',
           attachment_id: create(:attachment).id
       }].each do |attach|
          profile.profile_attachments.create(attach.select{|key,value|[:file_name, :profile_attachment_type_id, :description, :attachment_id].include? key})
      end
      {id: profile.id}
    end
  end


  def create_random_welfare_template(department_max=1, position_max =1)
    create(
        :welfare_template,
        template_chinese_name: "模板中文名-#{SecureRandom.uuid}",
        template_english_name: "模板英文名-#{SecureRandom.uuid}",
        annual_leave: random_select_item_from_array([0, 7, 12, 15]),
        sick_leave: random_select_item_from_array([0,6]),
        office_holiday: random_select_item_from_array([0, 1, 1.5, 2]),
        holiday_type: random_select_item_from_array(['none_holiday', 'force_holiday', 'force_public_holiday']),
        probation: random_select_item_from_array([0, 30, 60, 90, 180]),
        notice_period: random_select_item_from_array([0, 7, 30, 60]),
        double_pay: random_select_item_from_array([true, false]),
        reduce_salary_for_sick: random_select_item_from_array([true, false]),
        provide_uniform: random_select_item_from_array([true, false]),
        salary_composition: random_select_item_from_array([true, false]),
        over_time_salary: random_select_item_from_array([ 'one_point_two_times','one_point_two_and_two_times']),
        force_holiday_make_up: random_select_item_from_array(['one_money_and_one_holiday', 'two_holiday', 'two_money']),
        comment: "comment-#{@random_string}-#{(1..1000).to_a.sample}",
        belongs_to: create_random_department_with_position(department_max,position_max).reject{|key,value| value.length == 0 }
    )
  end

  def create_random_salary_template(department_max=1, position_max =1)

    create(
        :salary_template,
        template_chinese_name: "模板中文名-#{SecureRandom.uuid}",
        template_english_name: "模板英文名-#{SecureRandom.uuid}",
        basic_salary_unit: random_select_item_from_array(['mop','hkd']),
        bonus_unit: random_select_item_from_array(['mop','hkd']),
        attendance_award_unit: random_select_item_from_array(['mop','hkd']),
        house_bonus_unit: random_select_item_from_array(['mop','hkd']),
        total_count_unit: random_select_item_from_array(['mop','hkd']),
        basic_salary: Random.new.rand(1000),
        bonus: Random.new.rand(1000),
        attendance_award: Random.new.rand(1000),
        house_bonus: Random.new.rand(1000),
        tea_bonus: Random.new.rand(1000),
        kill_bonus: Random.new.rand(1000),
        performance_bonus: Random.new.rand(1000),
        charge_bonus: Random.new.rand(1000),
        commission_bonus: Random.new.rand(1000),
        receive_bonus: Random.new.rand(1000),
        exchange_rate_bonus: Random.new.rand(1000),
        guest_card_bonus: Random.new.rand(1000),
        respect_bonus: Random.new.rand(1000),
        new_year_bonus: Random.new.rand(1000),
        project_bonus: Random.new.rand(1000),
        product_bonus: Random.new.rand(1000),
        comment: "comment-#{@random_string}-#{(1..1000).to_a.sample}",  #{@random_string}-#{(1..1000).to_a.sample}
        belongs_to: create_random_department_with_position(department_max,position_max).reject{|key,value| value.length == 0 }
    )


  end



  #department_max 设置创建部门的数量,默认为1,不可以为负数;
  #position_max 设置创建部门下职位的最大数量最小为１,默认为1
  # 随机返回　每部门下存在的职位
  # example_model: {
  #     'department_id': ['position_id']
  # }
  #
  def create_random_department_with_position(department_max=1, position_max =1)
    position_max = 1 if position_max < 1
    department_ids = []
    department_max.times do
      department = create(:department)
      department_ids.push(department.id)
      Random.new.rand(1..position_max).times do
        department.positions << create(:position)
      end
    end

    options = {}
    department_ids.each do |department_id|
      options[department_id.to_s] = random_generate_new_array(Department.find(department_id).positions.map(&:id).map(&:to_s))
    end
    options
  end

  def create_medical_template_setting
    MedicalTemplateSetting.first_or_create(sections: [
        { employee_grade: 1, current_template_id: 1, impending_template_id: 6, effective_date: Time.zone.now },
        { employee_grade: 2, current_template_id: 2, impending_template_id: 7, effective_date: Time.zone.now },
        { employee_grade: 3, current_template_id: 3, impending_template_id: 8, effective_date: Time.zone.now },
        { employee_grade: 4, current_template_id: 4, impending_template_id: 9, effective_date: Time.zone.now },
        { employee_grade: 5, current_template_id: 5, impending_template_id: 9, effective_date: Time.zone.now }])
  end
  def create_train
    @current_user = create_test_user
    @current_user.add_role(@view_from_department_role) if @view_from_department_role
    create(:position, id: 1)
    create(:department, id: 1)
    create(:location, id: 1)

    TrainsController.any_instance.stubs(:current_user).returns(@current_user )
    test_train_template_1 = create(:train_template, creator_id: @current_user.id, train_template_type_id: create(:train_template_type).id)
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
    params = {
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
        comment: 'test3'

    }
    post trains_url, params: params
    Train.where(train_template_id: test_train_template_1.id).last
  end



  private
  def random_select_item_from_array(array)
    array[Random.new.rand(array.length)]
  end

  def random_generate_new_array(array)
    if  array.length == 0
      array.select! { random_select_item_from_array([true, false]) }
    else
      array
    end
  end
end
