require 'test_helper'

class WorkExperencesControllerTest < ActionDispatch::IntegrationTest

  setup do
    seaweed_webmock
    @profile = create_profile
    @current_user = create(:user)
    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:history, :WorkExperence, :macau)
    WorkExperencesController.any_instance.stubs(:current_user).returns(current_user)
    WorkExperencesController.any_instance.stubs(:authorize).returns(true)
    work_experence_1 = create(:work_experence, profile_id: @profile.id)
  end

  def test_report_index
    params = { location: @profile.user.location_id }
    get work_experences_url(params), as: :json
    assert_response :success

    assert_equal json_res['data'].count, 1

    params = { location: 2 }
    get work_experences_url(params), as: :json
    assert_response :success

    assert_equal json_res['data'].count, 0
  end

  def test_options
    get options_work_experences_url, as: :json
    assert_response :success
  end

  def test_columns
    get columns_work_experences_url, as: :json
    assert_response :success
  end

  def test_index

    test_id = create_test_user.id
    params = {
        company_organazition: 'company',
        former_head: 'head',
        job_description: 'description',
        creator_id:create_test_user.id,
        work_experience_company_phone_number: '123',
        work_experience_email: '123@123.com',
        work_experience_from: Time.zone.now,
        work_experience_position: 'macau',
        work_experience_reason_for_leaving: 'haha',
        work_experience_salary:'100',
        work_experience_to: Time.zone.now+1.day
    }
    get "/profiles/#{@profile.id}/work_experences/index_by_user", params: params
    assert_response :ok
  end

  def test_create
       params={
          company_organazition: 'company',
          former_head: 'head',
          job_description: 'description',
          user_id:create_test_user.id,
          work_experience_company_phone_number: '123',
          work_experience_email: '123@123.com',
          work_experience_from: Time.zone.now,
          work_experience_position: 'macau',
          work_experience_reason_for_leaving: 'haha',
          work_experience_salary:'100',
          work_experience_to: Time.zone.now+1.day
      }
       assert_difference('WorkExperence.count', 1) do
         post "/profiles/#{@profile.id}/work_experences", params: params, as: :json
         the_attach = @profile.work_experences.last.reload
         assert_equal the_attach.profile, @profile
         # assert_equal the_attach.description, attachment_params[:description]
         # assert_equal the_attach.profile_attachment_type, @profile_attachment_type
         assert_response :ok
       end
  end

  def _test_show
    get work_experence_url(work_experence)
    assert_response :success
  end

  def _test_update
    patch work_experence_url(work_experence), params: { work_experence: { company_organazition: work_experence.company_organazition, former_head: work_experence.former_head, job_description: work_experence.job_description, user_id: work_experence.user_id, work_experience_company_phone_number: work_experence.work_experience_company_phone_number, work_experience_email: work_experence.work_experience_email, work_experience_from: work_experence.work_experience_from, work_experience_position: work_experence.work_experience_position, work_experience_reason_for_leaving: work_experence.work_experience_reason_for_leaving, work_experience_salary: work_experence.work_experience_salary, work_experience_to: work_experence.work_experience_to } }
    assert_response 200
  end

  def _test_destroy
    assert_difference('WorkExperence.count', -1) do
      delete work_experence_url(work_experence)
    end

    assert_response 204
  end
end
