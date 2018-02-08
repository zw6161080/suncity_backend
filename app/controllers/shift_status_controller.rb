class ShiftStatusController < ApplicationController
  before_action :set_shift_status, only: [:update]

  def update
    authorize @shift_status
    @shift_status.update(shift_status_params)
    response_json :ok
  end

  private

  def shift_status_params
    params.require(:shift_status).permit(:is_shift)
  end

  def set_shift_status
    @shift_status = ShiftStatus.find(params[:id])
  end
end
