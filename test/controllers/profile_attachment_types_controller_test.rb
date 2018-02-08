require 'test_helper'

class ProfileAttachmentTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    current_user = create(:user)
    ProfileAttachmentTypesController.any_instance.stubs(:current_user).returns(current_user)
    ProfileAttachmentTypesController.any_instance.stubs(:authorize).returns(true)
  end

  test "get all profile attachment types list" do
    10.times do
      create(:profile_attachment_type)
    end
    
    profile = create_profile
    ProfileAttachmentType.first.profile_attachments.new(profile_id: profile.id).save

    get '/profile_attachment_types'
    assert_response :ok
    assert_equal json_res['data'].count, 10
    assert_equal json_res['data'].first.fetch('can_delete?'), false
  end


  test "post create one profile attachment type" do
    sample_type = build(:profile_attachment_type)

    assert_difference('ProfileAttachmentType.count', 1) do
      post '/profile_attachment_types', params: { 
        chinese_name: sample_type.chinese_name,
        english_name: sample_type.english_name,
        description: sample_type.description
      }
      assert_response :ok
    end
  end

  test "get show one profile attachment type" do
    sample_type = create(:profile_attachment_type)

    get "/profile_attachment_types/#{sample_type.id}"
    assert_equal sample_type.id, json_res['data']['id']
    assert_response :ok
  end

  test "patch update one profile attachment type" do
    sample_type = create(:profile_attachment_type)
    new_chinese_name = Faker::Lorem.word
    new_english_name = Faker::Lorem.word
    new_description = Faker::Lorem.sentence

    assert_difference('ProfileAttachmentType.count', 0) do
      patch "/profile_attachment_types/#{sample_type.id}", params: {
        chinese_name: new_chinese_name,
        english_name: new_english_name,
        description: new_description
      }
      sample_type.reload
      assert_equal sample_type.chinese_name, new_chinese_name
      assert_equal sample_type.english_name, new_english_name
      assert_equal sample_type.description, new_description
      assert_response :ok
    end
  end

  test "destroy one profile attachment type" do
    sample_type = create(:profile_attachment_type)
    assert_difference('ProfileAttachmentType.count', -1) do
      delete "/profile_attachment_types/#{sample_type.id}"
    end
    assert_response :ok

    sample_type = create(:profile_attachment_type)
    profile = create_profile
    profile_attachment = profile.profile_attachments.new(profile_id: profile)

    sample_type.profile_attachments << profile_attachment

    assert_difference('ProfileAttachmentType.count', 0) do
      delete "/profile_attachment_types/#{sample_type.id}"
    end
  end
end
