require 'test_helper'

class CardProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @current_user = create(:user)
    CardProfilesController.any_instance.stubs(:current_user).returns(@current_user)
    CardProfilesController.any_instance.stubs(:authorize).returns(true)
  end
  test 'card_profile show' do
    user_profile = create_profile
    create(:position).update(id: user_profile.data['position_information']['field_values']['position'])
    create(:department).update(id: user_profile.data['position_information']['field_values']['department'])
    card = create(:empo_card)
    post "/card_profiles", params: {empo_chinese_name: "珍妮",
                                    empo_english_name: "BOB",
                                    sex: "男",
                                    approved_job_name: card.approved_job_name,
                                    approved_job_number: card.approved_job_number,
                                    allocation_company: "太陽城集團旅遊有限公司",
                                    allocation_valid_date: "2017-01-02",
                                    approval_id: "1214124",
                                    report_salary_count: "9999",
                                    report_salary_unit: "HKD",
                                    labor_company: "待定",
                                    certificate_type: "護照",
                                    certificate_id: "777777",
                                    status: '已打指模',
                                    card_id: "11111",
    }, as: :json
    assert_response :ok
    profile = CardProfile.first
    patch "/card_profiles/#{profile.id}", params: {status: '已取消', empoid: user_profile.user.empoid}, as: :json

    get "/card_profiles/#{CardProfile.first.id}"

    arr = ["id", 'head', "employ_information", "quota_information",
           "certificate_information", "street_paper_information",
           "card_information", "card_attachment_information",
           "card_history_information", "comment_information", 'record_information']
    assert_response :ok
    assert_equal arr, json_res['data'].keys
  end

  test 'card_profile create' do
    card = create(:empo_card)
    Role.create(id: 6)
    assert_difference('MessageInfo.count') do
      post "/card_profiles", params: {empo_chinese_name: "珍妮",
                                      empo_english_name: "BOB",
                                      sex: "男",
                                      approved_job_name: card.approved_job_name,
                                      approved_job_number: card.approved_job_number,
                                      allocation_company: "太陽城集團旅遊有限公司",
                                      allocation_valid_date: Time.zone.now.to_date + 50.day,
                                      approval_id: "1214124",
                                      report_salary_count: "9999",
                                      report_salary_unit: "HKD",
                                      labor_company: "待定",
                                      certificate_type: "passport",
                                      certificate_id: "777777",
                                      status: 'fingermold',
                                      card_id: "11111",
                                      card_attachments: [
                                        {attachment_id: 1,
                                         file_name: 'hzg.jpg',
                                         category: 'passport'},
                                      ],
                                      card_histories: [
                                        {certificate_valid_date: '1990-01-01',
                                         new_or_renew: 'new',
                                        },
                                        {certificate_valid_date: '2000-01-01',
                                         new_or_renew: 'new',
                                        }
                                      ]
      }, as: :json
    end
    assert_response :ok
    assert_equal 'fingermold', CardProfile.first.status
    assert_equal 2, CardProfile.first.card_histories.count
    assert_equal 1, CardProfile.first.card_attachments.count
    assert_equal 1, EmpoCard.first.used_number


  end
  #
  test 'card_profile update' do
    user_profile = create_profile
    card = create(:empo_card)
    post "/card_profiles", params: {empo_chinese_name: "珍妮",
                                    empo_english_name: "BOB",
                                    sex: "男",
                                    approved_job_name: card.approved_job_name,
                                    approved_job_number: card.approved_job_number,
                                    allocation_company: "太陽城集團旅遊有限公司",
                                    allocation_valid_date: "2017-01-02",
                                    approval_id: "1214124",
                                    report_salary_count: "9999",
                                    report_salary_unit: "HKD",
                                    labor_company: "待定",
                                    certificate_type: "护照",
                                    certificate_id: "777777",
                                    status: 'fingermold',
                                    card_id: "11111",
    }, as: :json
    assert_response :ok
    user_profile.send(
      :edit_field, {field: 'type_of_id', new_value: 'passport', section_key: 'personal_information'}.with_indifferent_access
    )
    user_profile.save
    profile = CardProfile.first
    patch "/card_profiles/#{profile.id}", params: {status: 'canceled', empoid: user_profile.user.empoid}, as: :json
    assert_response :ok
    assert_equal user_profile.user.id, profile.reload.user_id
    assert_equal 'canceled', CardProfile.first.status
    assert_equal CardProfile.first.photo_id, user_profile.data['personal_information']['field_values']['photo']
    patch "/card_profiles/#{profile.id}", params: {approved_job_name: 'test'}, as: :json

    assert_equal 3, CardRecord.count

    CardProfile.any_instance.stubs(:allocation_valid_date).returns((Time.zone.now.to_date + 60.day))
    assert_difference('MessageInfo.count') do
      CardProfile.auto_send_message
    end

  end
  #
  test 'card_profile index' do

    9.times do
      create(:card_profile).update(certificate_valid_date: Time.zone.now + 1.day)
    end
    get "/card_profiles", params: {
      certificate_within_60: 'true',
      first_status: nil
    }
    assert_response :ok
    assert_equal 9, json_res['data'].length

  end

  test 'card_profile excel' do
    3.times do
      create(:card_profile)
    end
    get "/card_profiles/export_xlsx"
    assert_response :ok
    assert_equal 'application/json', response.content_type
  end

  test 'card_profile translate' do
    get "/card_profiles/translate"
    assert_response :ok
  end

  test 'test matching_search' do
    create(:position, id: 1)
    create(:department, id: 1)
    profile = create_profile
    tag = ['hong_kong_identity_card', 'valid_exit_entry_permit_eep_to_hk_macau', 'passport'].include? profile.data['personal_information']['field_values']['type_of_id']
    get "/card_profiles/matching_search", params: {
      text: profile.data['personal_information']['field_values']['chinese_name']
    }
    assert_response :ok
    if tag
      assert_equal json_res['data'].count, 1
    else
      assert_equal json_res['data'].count, 0
    end
  end

  test 'test current_card_profile_by_user' do
    test_id = create_test_user.id
    params={
      user_id: test_id
    }
    get "/card_profiles/current_card_profile_by_user", params: params
    assert_response :ok
  end


end
