class TrainingAbsenteesController < ApplicationController
  include StatementBaseActions
  include MineCheckHelper

  before_action :set_training_absentee, only: [:show, :update]

  before_action :authorize_action, only: [:index, :columns, :options]
  before_action :set_user, only: [:index, :columns, :options]
  before_action :myself?, only: [:index, :columns, :options], if: :entry_from_mine?
  def authorize_action
    authorize TrainingAbsentee unless entry_from_mine?
  end


  # GET /training_absentees/1
  def show
    authorize TrainingAbsentee
    data = @training_absentee.as_json(include: [
        :user,
        {train_class: {include: [:title, :train]}},
    ])
    data['submit_date']      = @training_absentee.submit_date.strftime('%Y/%m/%d %H:%M') if @training_absentee.submit_date
    data['train_date']       = @training_absentee.decorate_train_date
    data['train_class_time'] = @training_absentee.decorate_train_class_time
    response_json data
  end

  # POST /training_absentees
  def create
    authorize TrainingAbsentee
    training_absentee = TrainingAbsentee.create(training_absentee_params.as_json.merge(
        has_submitted_reason: false, has_been_exempted: false))
    response_json training_absentee
  end

  # PATCH/PUT /training_absentees/1
  def update
    authorize TrainingAbsentee
    case @training_absentee.has_submitted_reason
      when false then
        temp = training_absentee_params
                   .permit(:has_submitted_reason, :has_been_exempted, :absence_reason, :submit_date)
                   .merge(has_submitted_reason: true, submit_date: Time.zone.now)
      when true then
        temp = training_absentee_params
                   .permit(:has_been_exempted, :absence_reason)
    end
    if @training_absentee.update(temp)
      render json: @training_absentee
    else
      render json: @training_absentee.errors, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find_by_empoid(params[:employee_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_training_absentee
      @training_absentee = TrainingAbsentee.detail_by_id params[:id]
    end

    # Only allow a trusted parameter "white list" through.
    def training_absentee_params
      params.require(:training_absentee).permit(*TrainingAbsentee.create_params)
    end
end
