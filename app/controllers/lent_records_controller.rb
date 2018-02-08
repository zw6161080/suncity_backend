class LentRecordsController < ApplicationController
  include LentRecordHelper
  include MineCheckHelper
  before_action :set_lent_record, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user, :temporary_stadium_is_ok]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?


  def can_create
    result = TimelineRecordService.can_lent_record_create(params)
    render json: { result: result }
  end

  def can_update
    result = TimelineRecordService.can_lent_record_update(params)
    render json: { result: result }
  end

  # GET /lent_records/1
  def show
    render json: @lent_record, adapter: :attributes
  end

  # POST /lent_records
  def create
    authorize LentRecord
    raise '时间不符合创建规则' unless TimelineRecordService.can_lent_record_create(params)
    user = User.find(lent_record_params[:user_id])
    @lent_record = LentRecord.new(lent_record_params.merge({original_hall_id: user.location_id}))
    if  @lent_record.save
      LentRecord.update_roster_after_create(@lent_record, current_user)
      render json: @lent_record, status: :created, location: @lent_record, adapter: :attributes
    else
      render json: @lent_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /lent_records/1
  def update
    authorize LentRecord
    raise '时间不符合更新规则' unless TimelineRecordService.can_lent_record_update(params)
    old_record_info = @lent_record.dup
    if  @lent_record.update(update_params)
      Rails.logger.info "#{old_record_info.as_json}"
      LentRecord.update_roster_after_destroy(old_record_info)
      LentRecord.update_roster_after_create(@lent_record, current_user)
      render json: @lent_record, adapter: :attributes
    else
      render json: @lent_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /lent_records/1
  def destroy
    LentRecord.update_roster_after_destroy(@lent_record)
    @lent_record.destroy
  end

  def temporary_stadium_is_ok
     result  = LentRecord.can_lent_by_department?(ProfileService.department(@user, Time.zone.parse(params[:lent_begin])).id, params[:temporary_stadium_id]) rescue false
     render json: {can_create_or_update: result}
  end

  def index_by_user

    authorize LentRecord unless entry_from_mine?

    render json: LentRecord.where(user: user_id_params).order(lent_begin: :desc), adapter: :attributes
  end

  def lent_information_options
    render json: LentRecord.lent_information_options
  end

  private
  def set_user
    @user = User.find(params[:user_id])
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_lent_record
    @lent_record = LentRecord.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def lent_record_params
    params.require(lent_required_array)
    params.permit(lent_required_array + lent_permitted_array)
  end

  def update_params
    params.permit(lent_required_array + lent_permitted_array)
  end



  def user_id_params
    params.require(:user_id)
  end
end
