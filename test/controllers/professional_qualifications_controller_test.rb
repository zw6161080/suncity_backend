require 'test_helper'

class ProfessionalQualificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @profile = create_profile
    @professional_qualification = create(:professional_qualification,
                                         profile_id: @profile.id,
                                         professional_certificate: 'test',
                                         orgnaization: 'test',
                                         issue_date: Time.zone.now
    )
  end

  def test_columns
    get columns_professional_qualifications_url
    assert_response :success
  end

  def test_options
    get options_professional_qualifications_url
    assert_response :success
  end

  def test_index_by_user
    get index_by_user_profile_professional_qualifications_url(@profile)
    assert_response :success

    assert_equal json_res['data'].count, 1
  end

  def test_index
    params = {
        location: @profile.user.location_id
    }
    get professional_qualifications_url(params), as: :json
    assert_response :success
    assert_equal json_res['data'].count, 1
  end

  def test_create
    params = {
        profile_id: @profile.id,
        professional_certificate: 'test',
        orgnaization: 'test',
        issue_date: Time.zone.now
    }
    assert_difference('ProfessionalQualification.count') do
      post profile_professional_qualifications_url(@profile), params: params
    end

    assert_response :success
  end

  def test_update
    params = {
        profile_id: @profile.id,
        professional_certificate: 'test1',
        orgnaization: 'test1',
        issue_date: Time.zone.now
    }
    patch professional_qualification_url(@professional_qualification), params: params
    assert_response :success
  end

  def test_destroy
    assert_difference('ProfessionalQualification.count', -1) do
      delete professional_qualification_url(@professional_qualification)
    end
    assert_response :success
  end
end
