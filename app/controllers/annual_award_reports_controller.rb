class AnnualAwardReportsController < ApplicationController
  before_action :set_annual_award_report, only: [:show, :update, :destroy, :grant]

  # GET /annual_award_reports
  def index
    authorize AnnualAwardReport
    @annual_award_reports = AnnualAwardReport.all

    render json: @annual_award_reports
  end

  # GET /annual_award_reports/1
  def show
    authorize AnnualAwardReport
    render json: @annual_award_report
  end

  # POST /annual_award_reports
  def create
    authorize AnnualAwardReport
    @annual_award_report = AnnualAwardReport.create_with_params(annual_award_report_params)

    if @annual_award_report
      render json: @annual_award_report, status: :created, location: @annual_award_report
    else
      render json: @annual_award_report.errors, status: :unprocessable_entity
    end
  end


  # DELETE /annual_award_reports/1
  def destroy
    authorize AnnualAwardReport
    render json: @annual_award_report.destroy
  end

  def grant_type_options
    render json: AnnualAwardReport.grant_type_options
  end


  def grant
    authorize AnnualAwardReport
    render json: @annual_award_report.grant
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_annual_award_report
      @annual_award_report = AnnualAwardReport.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def annual_award_report_params
      params.require(required_array)
      params.permit(required_array - [:year_month, :award_date]).merge(grant_type_rule: params[:grant_type_rule], year_month:
      Time.zone.parse(params[:year_month]), award_date: Time.zone.parse(params[:award_date]))
    end
    def required_array
      [:year_month, :annual_attendance_award_hkd, :annual_bonus_grant_type, :grant_type_rule, :absence_deducting, :notice_deducting,
      :late_5_times_deducting, :sign_card_deducting, :one_letter_of_warning_deducting, :two_letters_of_warning_deducting,
      :each_piece_of_awarding_deducting, :method_of_settling_accounts, :award_date]
    end
end
