class AwardRecordsController < ApplicationController
  include MineCheckHelper
  before_action :set_award_record, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?

  # GET /award_records
  def index
    @award_records = AwardRecord.all

    render json: @award_records
  end

  # GET /award_records/1
  def show
    render json: @award_record
  end

  # POST /award_records
  def create
    authorize  AwardRecord
    @award_record = AwardRecord.new(award_record_params.merge(creator_id: current_user.id))

    if @award_record.save
      render json: @award_record, status: :created, location: @award_record
    else
      render json: @award_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /award_records/1
  def update
    authorize  AwardRecord
    if @award_record.update(update_params.merge(creator_id: current_user.id))
      render json: @award_record
    else
      render json: @award_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /award_records/1
  def destroy
    authorize  AwardRecord
    @award_record.destroy
  end

  def index_by_user

    authorize AwardRecord  unless entry_from_mine?

    render json: AwardRecord.where(user_id: user_id_params).order(created_at: :desc)
  end

  private

    def set_user
      @user = User.find(params[:user_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_award_record
      @award_record = AwardRecord.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def award_record_params
      params.require(record_required_array)
      params.permit(record_required_array + record_permitted_array)
    end

    def update_params
      params.permit(record_required_array + record_permitted_array)
    end

    def record_required_array
      [:user_id, :content, :award_date, :reason]
    end

    def record_permitted_array
      [:comment]
    end


    def user_id_params
      params.require(:user_id)
    end
end
