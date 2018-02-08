class AudiencesController < ApplicationController
  before_action :set_applicant_position, except: [:statuses, :mine]

  def mine
    result = current_user.audiences.includes(:applicant_position).where.not(applicant_positions: {id: nil}).as_json(
      methods: [:first_interview, :applicant_profile],
      include: [:creator, :applicant_position]
      )

    response_json result
  end

  def create
    audience = @applicant_position.audiences.create(params.permit(:status, :comment, :time))
    audience.user = User.find_by_email(params[:user_email])
    audience.creator = current_user
    audience.save

    LogService.new(:audience_created, current_user, audience).save_log(@applicant_position)
    Message.add_task(audience, "audience_created", audience.user_id)

    response_json
  end

  def update
    audience = @applicant_position.audiences.find(params[:id])
    audience.assign_attributes(params.permit(:status, :comment, :time))
    changes = audience.changes
    result = audience.save

    LogService.new(:audience_updated, current_user, audience, changes).save_log(@applicant_position) if result
    recruit_group_users = Role.find_by(key: 'recruit_group')&.users&.ids
    Message.add_task(audience, "audience_#{params[:status]}", recruit_group_users) if (params[:status] && !recruit_group_users.empty?)

    response_json result
  end

  def statuses
    result = Audience.statuses

    response_json result
  end

  private

  def set_applicant_position
    @applicant_position = ApplicantPosition.find(params[:applicant_position_id])
  end

end
