class SmsJob < ApplicationJob
  queue_as :sms

  def perform(sms)
    sms.send_msg
  end
end
