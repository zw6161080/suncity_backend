class ResignationRecordsController < ApplicationController
  include ResignationRecordHelper
  include MineCheckHelper
  before_action :set_resignation_record, only: [:show, :update, :destroy, :month_salary_report_item_has_granted]
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only: [:index_by_user], if: :entry_from_mine?


  # GET /resignation_records/1
  def show
    render json: @resignation_record, adapter: :attributes
  end

  # POST /resignation_records
  def create
    authorize ResignationRecord
    @resignation_record = ResignationRecord.new(resignation_record_params)
    if @resignation_record.save
      render json: @resignation_record, status: :created, location: @resignation_record, adapter: :attributes
    else
      render json: @resignation_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /resignation_records/1
  def update
    authorize ResignationRecord
    if @resignation_record.update(update_params)
      render json: @resignation_record, adapter: :attributes
    else
      render json: @resignation_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /resignation_records/1
  def destroy
    authorize ResignationRecord
    @resignation_record.destroy
  end

  def index_by_user

    authorize ResignationRecord unless entry_from_mine?

    render json: ResignationRecord.where(user: user_id_params).order(resigned_date: :desc), adapter: :attributes
  end

  def resignation_information_options
    render json: ResignationRecord.resignation_information_options
  end

  #validates
  def month_salary_report_item_has_granted
    render json:  {can_destroy:  @resignation_record.salary_value_can_be_destroy?}
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_resignation_record
    @resignation_record = ResignationRecord.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.

  def resignation_record_params
    params.require(resignation_required_array)
    params.permit(resignation_required_array + resignation_permitted_array)
  end

  def update_params
    params.permit(resignation_required_array + resignation_permitted_array)
  end


  def user_id_params
    params.require(:user_id)
  end
end
