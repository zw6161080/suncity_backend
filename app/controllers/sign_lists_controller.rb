class SignListsController < ApplicationController
  before_action :set_sign_list, only: [:update]
  def update
    response_json @sign_list.update_with_params(params.permit(*SignList.create_params), params['operator'])
  end
  private
  def set_sign_list
    @sign_list = SignList.find(params[:id])
  end
end
