class BonusElementMonthSharesController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  before_action :set_bonus_element_month_share, only: [:show, :update]

  # GET /bonus_element_month_shares
  def index
    authorize BonusElementMonthShare
    @bonus_element_month_shares = BonusElementMonthShare.query(bonus_element_month_share_query_params)
    respond_to do |format|
      format.json {
        render json: @bonus_element_month_shares
      }
      format.xlsx {
        bonus_element_month_share_export_num = Rails.cache.fetch('bonus_element_month_share_export_number_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+ bonus_element_month_share_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('bonus_element_month_share_export_number_tag', bonus_element_month_share_export_num + 1)
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t('bonus_element_month_shares.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateBonusElementMonthSharesTableJob.perform_later(query_ids:  @bonus_element_month_shares.ids, query_model: 'bonus_element_month_shares', float_salary_month_entry_id: params[:float_salary_month_entry_id], my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  # # GET /bonus_element_month_shares/1
  # def show
  #   render json: @bonus_element_month_share
  # end

  # PATCH/PUT /bonus_element_month_shares/1
  def update
    authorize BonusElementMonthShare
    if @bonus_element_month_share.update(bonus_element_month_share_params)
      render json: @bonus_element_month_share
    else
      render json: @bonus_element_month_share.errors, status: :unprocessable_entity
    end
  end

  # def batch_update
  #   if BonusElementMonthShare.batch_update(bonus_element_month_share_batch_update_params[:updates])
  #     render json: { success: true }, status: :ok
  #   else
  #     render json: { error: 'update failed' }, status: :unprocessable_entity
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bonus_element_month_share
      @bonus_element_month_share = BonusElementMonthShare.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def bonus_element_month_share_params
      params
        .require(:bonus_element_month_share)
        .permit(:shares)
    end

    def bonus_element_month_share_query_params
      params.permit(
        :location_id,
        :department_id,
        :float_salary_month_entry_id,
        :bonus_element_id,
        :year_month
      )
    end

    def bonus_element_month_share_batch_update_params
      params
        .require(:bonus_element_month_share)
        .permit(updates: [:id, :shares])
    end
end
