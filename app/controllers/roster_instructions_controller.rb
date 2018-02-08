class RosterInstructionsController < ApplicationController
  before_action :roster_instruction
  def update
    authorize RosterInstruction
    if @roster_instruction.update(update_params)
      render json: @roster_instruction
    else
      render json: @roster_instruction.errors, status: :unprocessable_entity
    end
  end

  private
  def roster_instruction
    @roster_instruction = RosterInstruction.find(params[:id])
  end

  def update_params
    params.permit([:comment])
  end
end
