require 'test_helper'
  class EmpoCardsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @current_user = create(:user)
      EmpoCardsController.any_instance.stubs(:current_user).returns(@current_user)
    end

    test 'empo_card create' do
      job = create(:approved_job)
      post "/empo_cards",params: {approved_job_id:job.id,
                                  approved_job_number: "kkkkk",
                                  allocation_valid_date:'1992/07/14',
                                  approval_valid_date:'1992/07/14',
                                  approved_number:'12',
      }
      assert_response :ok
      assert_equal job.approved_job_name, EmpoCard.first.approved_job_name
    end
    #
    test 'empo_card index' do
      job = create(:approved_job)
      create(:empo_card).update(approved_job_id: job.id)
      create(:empo_card).update(approved_job_id: job.id)
      get "/empo_cards",params: {id: job.id}
      assert_response :ok
      assert_equal 2, json_res['data'].count
    end

    test 'empo_card update' do
      card = create(:empo_card)
      job = create(:approved_job)
      card.approved_job_name = job.approved_job_name
      job.number= 1
      job.save
      card.save
      patch "/empo_cards/#{card.id}",params: {approved_job_number:'22222',}
      assert_response :ok
      assert_equal '22222', EmpoCard.first.approved_job_number
      assert_equal 1, ApprovedJob.count
      assert_equal 1, ApprovedJob.first.number
    end
    test 'empo_card destroy' do
      card = create(:empo_card)
      card.update(approved_job_id: create(:approved_job).id)
      delete "/empo_cards/#{card.id}"
      assert_response :ok
      assert_equal 0, EmpoCard.all.count
      assert_equal 0, ApprovedJob.first.number
    end
    #
    test 'destroy_job_with_cards' do

      job = create(:approved_job)
      create(:empo_card).update(approved_job_id: job.id)
      create(:empo_card).update(approved_job_id: job.id)
      create(:empo_card).update(approved_job_id: job.id)
      create(:empo_card).update(approved_job_id: job.id)
      get "/empo_cards/destroy_job_with_cards",    params: {id: job.id}
      assert_response :ok
      assert_equal 0, EmpoCard.count
      assert_equal 0, ApprovedJob.count
    end
  end


