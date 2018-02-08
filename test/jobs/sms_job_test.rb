require 'test_helper'
require 'sidekiq/testing'

class SmsJobTest < ActiveSupport::TestCase
  setup do
    Sidekiq::Testing.fake!
  end

  test 'perform' do
    Sidekiq::Testing.fake!
    sms = create(:sms)

    assert_difference('Sidekiq::Queues["sms"].size', 1) do
      SmsJob.perform_later(sms)
    end
  end
end
