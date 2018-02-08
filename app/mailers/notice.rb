class Notice < ApplicationMailer

  TYPES = [
      :audience_choose_needed_to_interviewer,
      :audience_agreed_to_hr,
      :audience_refused_to_hr,
      :interview_to_interviewer
    ]

  def send_mail_obj(applicant_position, mail_obj)
    mail(
      :to => mail_obj.to,
      :subject => mail_obj.subject,
      :content_type => "text/html",
      :body => mail_obj.body.to_s.gsub("\n", "<br />")
    )
  end

  def general_email(mail_obj)
    mail(
      :to => mail_obj.to,
      :subject => mail_obj.subject,
      :content_type => "text/html",
      :body => mail_obj.body.to_s.gsub("\n", "<br />")
    )
  end

  # def self.send_mail_obj(applicant_position, mail_obj)
  #   mail(
  #     :to => mail_obj.to,
  #     :subject => mail_obj.subject,
  #     :content_type => "text/html",
  #     :body => mail_obj.body.to_s.gsub("\n", "<br />")
  #   )
  # end

end
