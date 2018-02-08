require 'test_helper'

class LanguageSkillsControllerTest < ActionDispatch::IntegrationTest
  setup do
    seaweed_webmock
    @current_user = create(:user)
    LanguageSkillsController.any_instance.stubs(:current_user).returns(current_user)
    LanguageSkillsController.any_instance.stubs(:authorize).returns(true)
  end

  def test_show
    params = {
        language_chinese_writing: 'excellent',
        language_skill: 'sdf'


    }
    get "/users/#{@current_user.id}/language_skill", params: params
    assert_response :success

    profile = create_test_user.profile
    create(:language_skill,
           user_id:profile.user.id,
           language_chinese_writing: 'excellent',
           language_contanese_speaking: 'excellent',
           language_contanese_listening: 'excellent',
           language_skill: 'sdf',
           language_mandarin_speaking: 'excellent',
           language_mandarin_listening: 'excellent',
           language_english_speaking: 'excellent',
           language_english_listening: 'excellent',
           language_english_writing: 'excellent',
           language_other_name: 'excellent',
           language_other_speaking: 'excellent',
           language_other_listening: 'excellent',
           language_other_writing: 'excellent',

    )
    get "/users/#{@current_user.id}/language_skill"
    assert_response :success
  end

  def test_update
    params = {
        language_chinese_writing: 'excellent',
        language_skill: 'sdf'
    }
    patch "/users/#{@current_user.id}/language_skill", params: params, as: :json
    assert_response :success

    profile = create_test_user.profile
    create(:language_skill,
           user_id:profile.user.id,
           language_chinese_writing: 'excellent',
           language_contanese_speaking: 'excellent',
           language_contanese_listening: 'excellent',
           language_skill: 'sdf',
           language_mandarin_speaking: 'excellent',
           language_mandarin_listening: 'excellent',
           language_english_speaking: 'excellent',
           language_english_listening: 'excellent',
           language_english_writing: 'excellent',
           language_other_name: 'excellent',
           language_other_speaking: 'excellent',
           language_other_listening: 'excellent',
           language_other_writing: 'excellent',

    )
    params = {
        language_skill: 'sdf'
    }
    patch "/users/#{@current_user.id}/language_skill", params: params, as: :json
    assert_response :success
  end



end
