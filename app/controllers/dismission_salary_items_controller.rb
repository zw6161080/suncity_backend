class DismissionSalaryItemsController < ApplicationController
  include StatementBaseActions

  # PATCH /dismission_salary_items/1/approve
  def approve
    if DismissionSalaryItem.find(params[:id]).approve
      render json: { success: true }, status: :ok
    else
      render status: :conflict
    end
  end

end
