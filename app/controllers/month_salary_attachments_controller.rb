class MonthSalaryAttachmentsController < ApplicationController
  def show
    render json: MonthSalaryAttachment.find(params[:id])
  end
end
