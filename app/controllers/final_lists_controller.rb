class FinalListsController < ApplicationController
  before_action :set_final_list, only: [:update, :train_result]

  def update
    ActiveRecord::Base.transaction do
      @final_list.train_classes.clear
      @final_list.train_classes.clear unless params['_json'].empty?
      params['_json'].each do |item|
        @final_list.train_classes << TrainClass.find(item)
      end
      response_json
    end
  end

  def train_result
    update_supervisor_assessment(@final_list, params[:train_result])
    render json: @final_list.update_result(params.permit(:train_result, :comment))
  end

  private
  def set_final_list
    @final_list = FinalList.find(params[:id])
  end

  def update_supervisor_assessment(final_list, result)
    train = Train.find(final_list.train_id)
    user = User.find(final_list.user_id)
    sa = SupervisorAssessment.where(train_id: train.id, user_id: user.id).first
    if sa
      sa.training_result = result == 'train_pass' ? 0 : 1
      sa.save!
    end
  end
end
