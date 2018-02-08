require 'test_helper'
require 'sidekiq/testing'

class EmailJobTest < ActiveSupport::TestCase
  setup do
    Sidekiq::Testing.fake!
  end

  test 'perform' do
    applicant_position = create(:applicant_position)
    mail_obj = create(:email_object)

    assert_difference('Sidekiq::Queues["email"].size', 1) do
      EmailJob.perform_later('send_mail_obj', applicant_position, mail_obj)
    end
  end
end