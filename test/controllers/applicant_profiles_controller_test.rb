require 'test_helper'

class ApplicantProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
  ApplicantProfilesController.any_instance.stubs(:current_user).returns(current_user)
  ApplicantProfilesController.any_instance.stubs(:authorize).returns(true)
  end
  # test '获取申请职位模版' do
  #   get '/applicant_profiles/template', params: {region: 'macau'}
  #   assert_response :ok
  #   get '/applicant_profiles/template', params: {region: 'manila'}
  #   assert_response :ok
  # end
  # test '测试普通搜索' do
  #   profile = create_applicant_profile
  #   get '/applicant_profiles', params: {
  #       region: 'macau',
  #       department_id: Job.first.department_id,
  #       position_id: Job.first.position_id
  #   }
  #   assert_response :ok
  #   assert_equal 1, json_res['data']['profiles'].count
  # end
  # test '测试高级搜索' do
  #   profile = create_applicant_profile
  #   get '/applicant_profiles', params: {
  #     region: 'macau',
  #     advance_search: true,
  #     chinese_name: profile.chinese_name,
  #     english_name: profile.english_name,
  #     id_card_number: profile.id_card_number
  #   }
  #
  #   assert_response :ok
  #   assert_equal 3, json_res['data']['profiles'].count
  # end
  #
  test '创建求职者资料' do
    attachment_params = [{
      file_name: 'test file name',
      attachment_id: create(:attachment).id
    }]

    get_info_from_params = {
      selected: ['internet'],
      internet_detail: 'Internet Detail Test',
      others_detail: 'Others Detail Test'
    }

    real_get_info_from_params = {
      selected: ['internet'],
      internet_detail: 'Internet Detail Test',
      others_detail: ''
    }

    get '/applicant_profiles/template', params: {region: 'macau'}
    assert_response :ok

    template = json_res['data']
    filled_template = fill_profile_template(template)

    current_user = create_test_user
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:create, 'ApplicantProfile', 'macau')
    current_user.add_role(@admin_role)
    message_test_mock
    assert_difference(['ApplicantProfile.count', 'ApplicantAttachment.count'], 1) do
      assert_difference(['ApplicationLog.count'], 3) do
        post '/applicant_profiles', params: {
          sections: filled_template,
          region: 'macau',
          attachments: attachment_params,
          get_info_from: get_info_from_params
        },
        headers: {
          Token: current_user.token
        }, as: :json
        assert_response :ok
        assert_equal ApplicantProfile.last.get_info_from, real_get_info_from_params.stringify_keys
        assert json_res['data'].key?('id')
      end
    end

    profile = ApplicantProfile.first
    assert_equal 'manual', profile.source

    id_number = filled_template.find{|field| field['key'] == 'personal_information'}['field_values']["id_number"]
    assert_equal id_number, profile.id_card_number
    profile.save
    profile.reload
    assert_equal id_number, profile.id_card_number

    res = profile.send('add_row',{
      section_key: "educational",
      new_row: {
        highest: 'true',
        certificate_issue_date: '1111/11/11',
        college_university: "111",
        diploma_degree_attained: '11111',
        educational_department: '111',
        from_mm_yyyy: '11/1111',
        graduate_level: '1111',
        graduated: 'true',
        to_mm_yyyy: '11/1111'
      }
    }.with_indifferent_access)
    profile.save!
    res = profile.send('add_row',{
      section_key: "educational",
      new_row: {
        highest: 'true',
        certificate_issue_date: '1111/11/11',
        college_university: "11123333",
        diploma_degree_attained: '11111',
        educational_department: '111',
        from_mm_yyyy: '11/1111',
        graduate_level: '1111',
        graduated: 'true',
        to_mm_yyyy: '11/1111'
      }
    }.with_indifferent_access)
    profile.save!

    patch "/applicant_profiles/#{profile.id}", params: {
      edit_action_type: 'add_row',
      params: {
        section_key: "educational",
        new_row: {
          highest: 'true',
          certificate_issue_date: '2222/11/11',
          college_university: "111",
          diploma_degree_attained: '11111',
          educational_department: '111',
          from_mm_yyyy: '11/1111',
          graduate_level: '1111',
          graduated: 'true',
          to_mm_yyyy: '11/1111'
        }
      }
    }
  end
  #
  # test '创建求职者资料 待定选项' do
  #   get '/applicant_profiles/template', params: {region: 'macau'}
  #   assert_response :ok
  #
  #   template = json_res['data']
  #   filled_template = fill_profile_template(template)
  #
  #   current_user = create(:user)
  # end
  # test 'iPad端上传求职者资料' do
  #   get '/applicant_profiles/template', params: {region: 'macau'}
  #   assert_response :ok
  #
  #   template = json_res['data']
  #   filled_template = fill_profile_template(template)
  #
  #   message_test_mock
  #   assert_difference(['ApplicantProfile.count'], 1) do
  #     assert_difference(['ApplicationLog.count'], 3) do
  #       post '/applicant_profiles', params: {
  #         sections: filled_template,
  #         region: 'macau',
  #         source: 'ipad'
  #       }
  #       assert_response :ok
  #       assert json_res['data'].key?('id')
  #     end
  #   end
  #
  #   profile = ApplicantProfile.first
  #   assert_equal 'ipad', profile.source
  #
  #   filled_template[1]["field_values"] = {'first_choice' => 'pending'}
  #
  #   assert_difference(['ApplicantProfile.count'], 1) do
  #     post '/applicant_profiles', params: {
  #       sections: filled_template,
  #       region: 'macau',
  #       source: 'ipad'
  #     }
  #     assert_response :ok
  #     assert json_res['data'].key?('id')
  #   end
  #
  #   profile = ApplicantProfile.first
  #   assert_equal 'ipad', profile.source
  # end
  #
  # test '獲取相同證件號碼的檔案列表' do
  #   profile1 = create_applicant_profile
  #   profile2 = create_applicant_profile
  #
  #   id_card_number = 'somenumber'
  #
  #   [profile1, profile2].each do |profile|
  #     profile.send('edit_field', {
  #       section_key: "personal_information",
  #       field: "id_number",
  #       new_value: id_card_number
  #     }.with_indifferent_access)
  #     profile.save
  #   end
  #
  #   get "/applicant_profiles/#{profile1.id}/same_id_card_number_profiles", params: {
  #     region: 'macau'
  #   }
  #   assert_response :ok
  #   assert_equal 2, json_res['data'].count
  # end
  #
  # test '获取求职者档案列表' do
  #   3.times do
  #     create_applicant_profile
  #   end
  #
  #   create_applicant_select_column_template
  #
  #   get '/applicant_profiles', params: {region: 'macau'}
  #   assert_response :ok
  #
  #   field_keys = json_res['data']['fields'].map do |field|
  #     field['key']
  #   end
  #
  #   assert field_keys.include?('apply_position')
  #   assert field_keys.include?('apply_department')
  #
  #   assert_equal ApplicantPosition.count, json_res['data']['profiles'].count
  #   assert json_res['data']['profiles'].first['apply_department']
  #   assert json_res['data']['profiles'].first['apply_position']
  #   assert json_res['data']['profiles'].first['apply_source']
  #   assert json_res['data']['profiles'].first['apply_date']
  #   assert json_res['data']['profiles'].first['apply_status']
  #
  #   get '/applicant_profiles', params: {
  #     region: 'macau',
  #     applicant_position_status: 'waiting_for_interview'
  #   }
  #   assert_response :ok
  #
  #   get '/applicant_profiles', params: {
  #     region: 'macau',
  #     created_at: ''
  #   }
  #   assert_response :ok
  # end
  #
  test '获取求职者档案详情' do
    profile = create_applicant_profile
    assert_equal ApplicantProfile::MANUAL_SOURCE, profile.source
    get "/applicant_profiles/#{profile.id}"
    assert_response :ok
    assert json_res['data'].key?('sections')
    assert json_res['data'].key?('first_applicant_position_id')
    assert json_res['data'].key?('second_applicant_position_id')
    assert json_res['data'].key?('third_applicant_position_id')
  end
  #
  test '修改求职者档案' do

    current_user = create(:user)
    ApplicantProfilesController.any_instance.stubs(:current_user).returns(current_user)
    ApplicantProfilesController.any_instance.stubs(:authorize).returns(true)

    profile = create_applicant_profile

    first_choice_id = profile.first_applicant_position_id

    #修改档案节中的字段
    new_pic_url = Faker::Avatar.image('foo')

    params = {
      edit_action_type: 'edit_field',
      params: {
        section_key: 'personal_information',
        field: 'photo',
        new_value: new_pic_url
      }
    }

    current_user = create(:user)
    ApplicantProfilesController.any_instance.stubs(:current_user).returns(current_user)

    message_test_mock
    assert_difference(['ApplicationLog.count'], 3) do
      patch "/applicant_profiles/#{profile.id}", params: params
      assert_response :ok
      profile.reload
      assert_equal new_pic_url, profile.data['personal_information']['field_values']['photo']

      assert_equal first_choice_id, profile.first_applicant_position_id
    end

    params = {
      edit_action_type: 'edit_applicant_no',
      params: { applicant_no: 'new_applicant_no' }
    }

    current_user = create(:user)
    ApplicantProfilesController.any_instance.stubs(:current_user).returns(current_user)

    message_test_mock
    assert_difference(['ApplicationLog.count'], 3) do
      patch "/applicant_profiles/#{profile.id}", params: params
      assert_response :ok
      profile.reload
      assert_equal 'new_applicant_no', profile.applicant_no
    end

    params = {
      edit_action_type: 'edit_get_info_from',
      params: {
        selected: ['internet', 'others'],
        internet_detail: 'Internet Detail Test',
        others_detail: 'Others Detail Test'
      }
    }

    current_user = create(:user)
    ApplicantProfilesController.any_instance.stubs(:current_user).returns(current_user)

    message_test_mock
    assert_difference(['ApplicationLog.count'], 3) do
      patch "/applicant_profiles/#{profile.id}", params: params
      assert_response :ok
      profile.reload
      assert_equal profile.get_info_from, params[:params].stringify_keys
    end

  end

  test '导出Excel' do
    3.times do
      create_applicant_profile
    end
byebug
    get '/applicant_profiles/export_xlsx_with_apply_source_apply_date_apply_status', params: {
        select_columns: ['required_to_hold_a_working_visa_in_order_to_work_in_the_macau']
    }
    assert_response :success
    assert_equal 'application/json', response.content_type
  end


  # test '导出Excel_with_apply_source_apply_date_apply_status' do
  #   3.times do
  #     create_applicant_profile
  #   end
  #
  #   get '/applicant_profiles/export_xlsx_with_apply_source_apply_date_apply_status'
  #   assert_response :success
  #   assert_equal 'application/xlsx', response.content_type
  # end
  #
  # test 'advance search params check' do
  #   10.times do
  #     create_applicant_profile
  #   end
  #
  #   all_chinese_name = ApplicantProfile.pluck(:chinese_name)
  #   #change last element of query array
  #   all_chinese_name[all_chinese_name.length - 1] = "a-fake-name"
  #   params = {
  #     search_type: 'chinese_name',
  #     search_data: all_chinese_name,
  #     region: 'macau'
  #   }
  #
  #   get '/applicant_profiles/advance_search_params_check', params: params
  #   assert_response :ok
  #   assert_equal 1, json_res['data']['unmatched_values'].length
  # end
end
