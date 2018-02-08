class ApplicationMailer < ActionMailer::Base

  layout 'mailer'
    
  default from: "noreply@yuelemon.com"
  # default from: "SUBMAIL "

end
