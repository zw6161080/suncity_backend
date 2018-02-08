# coding: utf-8
class EmailController < ApplicationController

  def delivery

    params[:body] += "

詳情請點擊鏈接進入系統：<a href=\"#{FRONTEND_URL}/#{params[:url]}\">#{FRONTEND_URL}/#{params[:url]}</a>
此郵件為系統自動發送，請勿回覆郵件。"

    mail_object = EmailObject.new(params.permit(:to, :subject, :body, :the_object, :the_object_id, :mark))
    mail_object.save

    sender(mail_object)
  end


  def delivery_email
    params[:body] += "
詳情請點擊鏈接進入系統：<a href=\"#{FRONTEND_URL}/#{params[:url]}\">#{FRONTEND_URL}/#{params[:url]}</a>
此郵件為系統自動發送，請勿回復郵件。"

    mail_object = EmailObject.new(params.permit(:to, :subject, :body))
    mail_object.save

    EmailJob.perform_later(:general_email.to_s, mail_object, nil)

    response_json
  end

  def types
    types = Notice::TYPES

    response_json types
  end

  def templates
    meta = {}
    @comment = ''
    if params[:audience_id]
      @audience = Audience.find_by_id(params[:audience_id])
      @applicant_position = @audience.applicant_position
      @applicant_profile = @applicant_position.applicant_profile
      meta = meta.merge({audience: @audience})
      @comment = @audience.comment
    elsif params[:interviewer_id]
      @interviewer = Interviewer.find_by_id(params[:interviewer_id])
      @interview = @interviewer.interview
      @applicant_position = @interview.applicant_position
      @applicant_profile = @applicant_position.applicant_profile
      meta = meta.merge({interviewer: @interviewer})
      @comment = @interviewer.comment
    elsif params[:interview_id]
      @interview = Interview.find_by_id(params[:interview_id])
      @applicant_position = @interview.applicant_position
      @applicant_profile = @applicant_position.applicant_profile
      meta = meta.merge({interview: @interview})
    elsif params[:applicant_position_id]
      @applicant_position = ApplicantPosition.find_by_id(params[:applicant_position_id])
      @applicant_profile = @applicant_position.applicant_profile
    end

    meta = meta.merge({
        applicant_position: @applicant_position,
        applicant_profile: @applicant_profile,
        position: @applicant_position.position,
        department: @applicant_position.department
      })
    target_department_name = @applicant_position.department.chinese_name rescue '待定'
    target_position_name = @applicant_position.position.chinese_name rescue '待定'
    subject_title = :audience_choose_needed_to_interviewer == params[:email_type].to_sym ? '面試邀請' : '面試回覆'
    subject = "#{@applicant_profile.applicant_no} (#{subject_title})—#{target_department_name} #{target_position_name}"

    template = ''
    if Notice::TYPES.include? params[:email_type].to_sym
      template = to_template(params[:email_type].to_sym, binding)
    end

    result = {
      subject: subject,
      body: template,
      meta: meta
    }

    response_json result
  end

  private

  def sender(mail_obj)
    email_type = :send_mail_obj
    applicant_position = ApplicantPosition.find(mail_obj.the_object_id)

    EmailJob.perform_later(email_type.to_s, mail_obj, applicant_position)

    LogService.new(:email_sent, current_user, mail_obj).save_log(applicant_position)

    response_json
  end

  def to_template(type, the_binding)
    html = File.open("#{Rails.root}/app/views/notice/#{type}.html.erb").read
    template = ERB.new(html)
    template.result(the_binding)
  end

end
