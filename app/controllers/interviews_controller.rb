class InterviewsController < ApplicationController
  before_action :set_applicant_position
  before_action :set_interview, only: [:update]

  def index_by_current_user
    raw_index
  end

  def raw_index
    result = @applicant_position.interviews.as_json(include: {
      interviewer_users: { only: [ :id, :empoid, :email, :chinese_name, :english_name ] }
    })
    response_json result
  end


  def index
    raw_index
  end

  def create
    interview = @applicant_position.interviews.create(params.permit(:time, :comment, :mark))
    interview.add_interviewers_by_ids(params[:user_ids], current_user) if params[:user_ids]
    LogService.new(:interview_created, current_user, interview).save_log(@applicant_position)

    recruit_group_users = Role.find_by(key: 'recruit_group')&.users&.ids
    # interviewers_user_ids(interview)
    Message.add_task(interview, :interview_created, recruit_group_users) unless recruit_group_users.empty?

    response_json
  end

  def update
    pre_result = @interview.result
    @interview.assign_attributes(params.permit(:time, :comment, :result, :score, :evaluation, :score, :need_again, :mark, :cancel_reason))
    changes = @interview.changes
    # @interview.add_interviewers_by_emails(params[:interviewer_emails], current_user) if params[:interviewer_emails]
    @interview.add_interviewers_by_ids(params[:interviewer_emails], current_user) if params[:interviewer_emails]
    result = @interview.save
    if result
      @interview.send_message_by_result(params[:result], changes, @applicant_position, current_user, pre_result)
    end
    response_json result
  end


  def interviewers
    authorize Interview
    interview = @applicant_position.interviews.find(params[:id])
    result = interview.interviewer_users.as_json(only: :email)

    response_json result
  end

  def add_interviewers
    interview = @applicant_position.interviews.find(params[:id])
    interview.add_interviewers_by_emails(params[:interviewer_emails], current_user)

    LogService.new(:interview_updated, current_user, interview).save_log(@applicant_position)

    response_json
  end

  def remove_interviewers
    interview = @applicant_position.interviews.find(params[:id])
    interview.remove_interviewers_by_emails(params[:interviewer_emails])

    LogService.new(:interview_updated, current_user, interview).save_log(@applicant_position)

    response_json
  end

  def resultes
    resultes = Interview.resultes

    response_json resultes
  end

  private

  def set_interview
    @interview = Interview.find(params[:id])
  end

  def set_applicant_position
    @applicant_position = ApplicantPosition.find(params[:applicant_position_id])
  end

  def interviewers_user_ids(interview)
    interview.interviewers.pluck(:user_id).uniq
  end


  def current_user_and_interviewers_user_ids(interview)
    user_ids = []
    user_ids += interview.interviewers.pluck(:user_id)
    user_ids += current_user.id
    user_ids.uniq
  end

end
