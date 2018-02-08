class ApplicationLogsController < ApplicationController

  def index
    result = ApplicationLog.where(applicant_position_id: params[:applicant_position_id]).order(created_at: :asc)
             .as_json(include: { user: { only: [:chinese_name, :english_name, :email] } })

    response_json result
  end

  def types
    result = ApplicationLog.new.behaviors

    response_json result
  end

end
