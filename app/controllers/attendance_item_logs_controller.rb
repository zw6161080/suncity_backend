class AttendanceItemLogsController < ApplicationController

  def index
    attendance_item_logs = AttendanceItemLog.includes(:user)
                             .where(attendance_item_id: params[:attendance_item_id])
                             .as_json(include: [:user])

    response_json attendance_item_logs
  end

end
