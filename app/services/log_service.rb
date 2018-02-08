class LogService

  attr_reader :behavior, :record

  def initialize(behavior, current_user, record=nil, changes={})
    @behavior = behavior
    @current_user = current_user
    @changes = changes
    @record = record
  end

  def save_log(the_applicant_position)
    the_applicant_position.application_logs.add_log(behavior) do |log|
      log.user = @current_user
      log.info = generate_log_info
    end
  end

  def self.add_log(behavior, current_user, the_applicant_position)
    ApplicationLog.add_log(behavior) do |log|
      log.user = current_user
      log.applicant_position = the_applicant_position
      yield log
    end
  end
  
  def generate_log_info
    info = {changes: @changes}
    info = info.merge({"#{@record.class.to_s.underscore}" => @record.attributes})
    info = info.merge(self.try("log_info_for_#{behavior}").to_h)
  end

  def log_info_for_interview_created
    {
      interviewer_users: @record.interviewer_users.pluck(:id, :chinese_name, :english_name),
    }
  end

  def log_info_for_interview_updated
    {
      interviewer_users: @record.interviewer_users.pluck(:id, :chinese_name, :english_name),
    }
  end

  def log_info_for_interviewer_updated
    {
      interview: @record.interview.attributes
    }
  end

  def log_info_for_email_sent
    {
      to_user: User.select(:id, :email, :chinese_name, :english_name).where(email: @record.to).map{ |u| u.attributes}
    }
  end

end
