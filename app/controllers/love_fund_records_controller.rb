class LoveFundRecordsController < ApplicationController
  def index_by_user
    user = User.find(params[:user_id])
    render json: LoveFundRecord.where(user_id: user.id).order(created_at: :desc)
  end
end
