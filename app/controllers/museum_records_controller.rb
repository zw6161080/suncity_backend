class MuseumRecordsController < ApplicationController
  include MuseumRecordHelper
  include MineCheckHelper
  before_action :set_museum_record, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user, :location_is_ok]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?


  def can_create
    result = TimelineRecordService.can_museum_record_create(params)
    render json: { result: result }
  end

  def can_update
    result = TimelineRecordService.can_museum_record_update(params)
    render json: { result: result }
  end

  # GET /museum_records/1
  def show
    render json: @museum_record, adapter: :attributes
  end

  # POST /museum_records
  def create
    authorize MuseumRecord
    raise '时间不符合创建规则' unless TimelineRecordService.can_museum_record_create(params)
    @museum_record = MuseumRecord.new(museum_record_params)

    if @museum_record.save
      MuseumRecord.update_roster_after_create(@museum_record, current_user)
      render json: @museum_record, status: :created, location: @museum_record, adapter: :attributes
    else
      render json: @museum_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /museum_records/1
  def update
    authorize MuseumRecord
    old_record_info = @museum_record.dup
    if @museum_record.update(update_params)
      MuseumRecord.update_roster_after_destroy(old_record_info)
      MuseumRecord.update_roster_after_create(@museum_record, current_user)
      render json: @museum_record, adapter: :attributes
    else
      render json: @museum_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /museum_records/1
  def destroy
    MuseumRecord.update_roster_after_destroy(@museum_record)
    @museum_record.destroy
  end

  def index_by_user

    authorize MuseumRecord unless entry_from_mine?

    render json: MuseumRecord.where(user: user_id_params).order(date_of_employment: :desc), adapter: :attributes
  end

  def museum_information_options
    render json: MuseumRecord.museum_information_options
  end

  def location_is_ok
    result  = MuseumRecord.can_museum_by_department?(ProfileService.department(@user, Time.zone.parse(params[:date_of_employment])).id, params[:location_id]) rescue false
    render json: {can_create_or_update: result}
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_museum_record
    @museum_record = MuseumRecord.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def museum_record_params
    params.require museum_required_array
    params.permit(museum_required_array + museum_permitted_array)
  end

  def update_params
    params.permit(museum_required_array + museum_permitted_array)
  end


  def user_id_params
    params.require(:user_id)
  end
end
