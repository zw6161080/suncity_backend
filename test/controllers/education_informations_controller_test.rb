require 'test_helper'

class EducationInformationsControllerTest < ActionDispatch::IntegrationTest

  setup do
    seaweed_webmock
    @profile = create_profile
    @current_user = create(:user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :EducationInformation, :macau)
    EducationInformationsController.any_instance.stubs(:current_user).returns(current_user)
    EducationInformationsController.any_instance.stubs(:authorize).returns(true)
    education_information_1 = create(:education_information, profile_id: @profile.id, creator_id: @current_user.id)
  end

  def test_columns
    get columns_education_informations_url, as: :json
    assert_response :success
  end

  def test_options
    get options_education_informations_url, as: :json
    assert_response :success
  end

  def test_report_index
    params = { location: [2] }
    get education_informations_url(params), as: :json
    assert_response :success

    params_1 = { location: [1] }
    get education_informations_url(params_1), as: :json
    assert_response :success

    assert_equal json_res['data'].count, 1
  end

  def test_index
    test_id = create_test_user.id
    params = {
        user_id:test_id,
        from_mm_yyyy:Time.zone.now,
        to_mm_yyyy:Time.zone.now+1.day,
        college_university:"daxue",
        educational_department:"computer",
        graduate_level:"benke",
        diploma_degree_attained:"shuoshi",
        certificate_issue_date:Time.zone.now,
        graduated:true,
        highest: true
    }
    get "/profiles/#{@profile.id}/education_informations/index_by_user", params: params
    assert_response :ok
  end

  def test_create
    assert_difference('EducationInformation.count') do
      post "/profiles/#{@profile.id}/education_informations", params: {
          user_id:create_test_user.id,
          from_mm_yyyy:Time.zone.now,
          to_mm_yyyy:Time.zone.now+1.day,
          college_university:"daxue",
          educational_department:"computer",
          graduate_level:"benke",
          diploma_degree_attained:"shuoshi",
          certificate_issue_date:Time.zone.now,
          graduated:true,
          highest: true
      }
    end

    assert_response :ok
  end

  def _test_show
    get education_information_url(education_information)
    assert_response :success
  end

  def _test_update
    patch education_information_url(education_information), params: { user_id:create_test_user.id,
                                                                      from_mm_yyyy:Time.zone.now,
                                                                      to_mm_yyyy:Time.zone.now+1.day,
                                                                      college_university:"daxue",
                                                                      educational_department:"computer",
                                                                      graduate_level:"benke",
                                                                      diploma_degree_attained:"shuoshi",
                                                                      certificate_issue_date:Time.zone.now,
                                                                      graduated:true,
                                                                      highest: true}
    assert_response 200
  end

  def _test_destroy
    assert_difference('EducationInformation.count', -1) do
      delete education_information_url(education_information)
    end

    assert_response 204
  end
end
