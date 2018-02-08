class AirTicketReimbursementsController < ApplicationController
  include AirTicketReimbursementHelper
  include MineCheckHelper
  before_action :set_air_ticket_reimbursement, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?


  # GET /air_ticket_reimbursements/1
  def show
    render json: @air_ticket_reimbursement, adapter: :attributes
  end

  # POST /air_ticket_reimbursements
  def create
    authorize AirTicketReimbursement
    #user = User.find(air_ticket_reimbursement_params[:user_id])
    @air_ticket_reimbursement = AirTicketReimbursement.new(air_ticket_params)
    if @air_ticket_reimbursement.save
      render json: @air_ticket_reimbursement, status: :created, location: @air_ticket_reimbursement, adapter: :attributes
    else
      render json: @air_ticket_reimbursement.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /air_ticket_reimbursements/1
  def update
    authorize AirTicketReimbursement
    if @air_ticket_reimbursement.update(air_ticket_params)
      render json: @air_ticket_reimbursement, adapter: :attributes
    else
      render json: @air_ticket_reimbursement.errors, status: :unprocessable_entity
    end
  end

  # DELETE /air_ticket_reimbursements/1
  def destroy
    authorize AirTicketReimbursement
    @air_ticket_reimbursement.destroy
  end

  def index_by_user
    authorize AirTicketReimbursement unless entry_from_mine?
    render json: AirTicketReimbursement.where(user_id: user_id_params), adapter: :attributes
  end


  private
    def set_user
      @user = User.find(params[:user_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_air_ticket_reimbursement
      @air_ticket_reimbursement = AirTicketReimbursement.find(params[:id])
    end

end
