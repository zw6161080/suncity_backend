class CareerRecordsController < ApplicationController
  include CareerRecordHelper
  include MineCheckHelper
  before_action :set_career_record, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user ]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?


  def can_create
    result = TimelineRecordService.can_career_record_create(params)
    render json: { result: result }
  end

  def can_update
    result = TimelineRecordService.can_career_record_update(params)
    render json: { result: result }
  end

  # GET /career_records/1
  def show
    render json: @career_record, adapter: :attributes
  end

  # POST /career_records
  def create
    authorize CareerRecord
    raise '时间不符合创建规则' unless TimelineRecordService.can_career_record_create(params)
    @career_record = CareerRecord.new(final_create_params(career_record_params).merge({inputer_id: current_user.id}))
    if @career_record.save
      CareerRecord.update_roster_after_create(@career_record, current_user)
      render json: @career_record, status: :created, location: @career_record, adapter: :attributes
    else
      render json: @career_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /career_records/1
  def update
    authorize CareerRecord
    raise '时间不符合更新规则' unless TimelineRecordService.can_career_record_update(params)
    older_record_info = @career_record.dup
    if @career_record.update(update_params)
      CareerRecord.update_roster_after_destroy(older_record_info)
      CareerRecord.update_roster_after_create(@career_record, current_user)
      render json: @career_record, adapter: :attributes
    else
      render json: @career_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /career_records/1
  def destroy
    unless @career_record.is_being_valid?
      CareerRecord.update_roster_after_destroy(@career_record)
      @career_record.destroy
      TimelineRecordService.update_valid_date(@career_record.user)
    end
  end

  def index_by_user

    authorize CareerRecord unless entry_from_mine?

    render json: CareerRecord.where(user: user_id_params).order(career_begin: :desc), adapter: :attributes
  end

  def career_information_options
    render json: CareerRecord.career_information_options
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end
    # Use callbacks to share common setup or constraints between actions.
    def set_career_record
      @career_record = CareerRecord.find(params[:id])
    end

end
