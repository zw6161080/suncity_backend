class SmsController < ApplicationController

  def templates
    templates = Sms.templates(params.permit(:first_interview_time, :second_interview_time, :third_interview_time, :contract_notice_time, :change_contract_time, :applicant_no, :position_name, :applicant_name))

    response_json templates
  end

  def delivery

    sms = Sms.new(params.permit(:to, :content, :title, :the_object, :the_object_id, :mark))
    sms.user_id = current_user.id
    sms.save
    SmsJob.perform_later(sms)
    content_changed =  params[:content_changed] ? {content_changed: true} : {}

    if :interview == params[:the_object]&.to_sym
      applicant_position = Interview.find(params[:the_object_id]).applicant_position
      LogService.new(:sms_sent, current_user, sms, content_changed).save_log(applicant_position)
    end

    response_json
  end

  def delivery_sms
    sms = Sms.new(params.permit(:to, :content))
    sms.user_id = current_user.id
    sms.save
    SmsJob.perform_later(sms)
    response_json
  end
end
