class WrwtsController < ApplicationController
  include MineCheckHelper
  before_action :set_wrwt, only: [:show, :update, :destroy]
  before_action :set_user, only: [:current_wrwt_by_user]
  before_action :myself?, only:[:current_wrwt_by_user], if: :entry_from_mine?
  # GET /wrwts
  def index
    @wrwts = Wrwt.all

    render json: @wrwts
  end

  # GET /wrwts/1
  def show
    render json: @wrwt
  end

  # POST /wrwts
  def create
    @wrwt = Wrwt.new(wrwt_params)

    if @wrwt.save
      render json: @wrwt, status: :created, location: @wrwt
    else
      render json: @wrwt.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /wrwts/1
  def update
    authorize Wrwt
    if @wrwt.update(update_params)
      render json: @wrwt
    else
      render json: @wrwt.errors, status: :unprocessable_entity
    end
  end

  # DELETE /wrwts/1
  def destroy
    @wrwt.destroy
  end

  def wrwt_information_options
    render json: Wrwt.wrwt_information_options
  end


  def current_wrwt_by_user
    authorize Wrwt unless entry_from_mine?
    render json: Wrwt.where(user_id: user_id_params).first
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wrwt
      @wrwt = Wrwt.find(params[:id])
    end

  def set_user
    @user = User.find(params[:user_id])
  end

    # Only allow a trusted parameter "white list" through.
    def wrwt_params
      params.require(required_array)
      params.permit(required_array + permitted_array)
    end
    def required_array
      [:user_id, :provide_airfare, :provide_accommodation]
    end

    def permitted_array
      [:airfare_type, :airfare_count]
    end

    def update_params
      params.permit(required_array - [:user_id] + permitted_array)
    end

    def user_id_params
      params.require(:user_id)
    end
end
