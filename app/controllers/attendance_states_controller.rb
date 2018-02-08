class AttendanceStatesController < ApplicationController
  def index
    parents = AttendanceState.includes(:children).where(parent_id: nil)
    response_json parents.as_json(include: [:children])
  end

  def update
    attendance_state = AttendanceState.find(params[:id])
    if attendance_state.update(attendance_state_params)
      response_json
    end
  end

  def create
    attendance_state = AttendanceState.new(attendance_state_params)

    if attendance_state.save
      response_json
    end
  end

  def destroy
    attendance_state = AttendanceState.find(params[:id])
    attendance_state.delete
    response_json
  end

  private
  def attendance_state_params
    params.permit(:code, :english_name, :chinese_name, :parent_id, :comment)
  end
end
