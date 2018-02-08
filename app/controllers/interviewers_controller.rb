class InterviewersController < ApplicationController

  def index
    interviewers = current_user.interviewers.includes([:interview, :applicant_position]).where.not(applicant_positions: {id: nil})
    data = interviewers.as_json(
        methods: :applicant_profile,
        include: {
          interview: { include: :applicant_position }
        })

    response_json data
  end
  alias_method :mine, :index

  def waiting_for_choose
    interviewers = current_user.interviewers.waiting_for_choose
    data = interviewers.as_json(
        methods: :applicant_profile,
        include: {
          interview: { include: :applicant_position }
        })

    response_json data
  end

  def waiting_for_interview
    interviewers = current_user.interviewers.waiting_for_interview
    data = interviewers.as_json(
        methods: :applicant_profile,
        include: {
          interview: { include: :applicant_position }
        })

    response_json data
  end

  def statuses
    statuses = Interviewer.statuses

    response_json statuses
  end

  def update_status
    interviewer = Interviewer.find(params[:id])
    interviewer.assign_attributes(params.permit(:status, :comment))
    changes = interviewer.changes
    result = interviewer.save

    applicant_position = interviewer.interview.applicant_position
    LogService.new(:interviewer_updated, current_user, interviewer, changes).save_log(applicant_position) if result
    if ['interview_agreed', 'interview_refused', 'interview_completed'].include?(params[:status])
      recruit_group_users = Role.find_by(key: 'recruit_group')&.users&.ids
      if params[:status] == 'interview_completed'
      # interview = interviewer.interview
      # sd_ids = (interview.interviewer_users&.pluck(:id) + recruit_group_users).compact.uniq
      # Message.add_task(interviewer, "interviewer_#{params[:status]}", sd_ids) unless sd_ids.empty?
      else
        Message.add_task(interviewer, "interviewer_#{params[:status]}", recruit_group_users) unless recruit_group_users.empty?
      end
    end

    response_json result
  end
end
