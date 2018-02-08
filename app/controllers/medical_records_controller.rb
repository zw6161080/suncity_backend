class MedicalRecordsController < ApplicationController
  before_action :set_medical_record, only: [:show, :update, :destroy]

  def index_by_user
    user = User.find(params[:user_id])
    render json: MedicalRecord.where(user_id: user.id).order(created_at: :desc)
  end

  # GET /medical_records
  def index
    @medical_records = MedicalRecord.all
    render json: @medical_records
  end

  # GET /medical_records/1
  def show
    render json: @medical_record
  end

  # POST /medical_records
  def create
    @medical_record = MedicalRecord.new(medical_record_params)

    if @medical_record.save
      render json: @medical_record, status: :created, location: @medical_record
    else
      render json: @medical_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /medical_records/1
  def update
    if @medical_record.update(medical_record_params)
      render json: @medical_record
    else
      render json: @medical_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /medical_records/1
  def destroy
    @medical_record.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medical_record
      @medical_record = MedicalRecord.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def medical_record_params
      params.fetch(:medical_record, {})
    end
end
