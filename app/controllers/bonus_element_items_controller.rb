class BonusElementItemsController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper

  before_action :set_bonus_element_item, only: [:show]

  # GET /bonus_element_items
  def index
    authorize BonusElementItem
    sort_column = sort_column_sym(params[:sort_column], :default)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)


    respond_to do |format|
      format.json {
        page = params.fetch(:page, 1)
        query = BonusElementItem.query(query_params, sort_column, sort_direction).page
        page = 1 if page.to_i > query.total_pages
        query = query.page(page).per(20)
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages
        }
        render json: query, root: 'data', meta: meta, include: '**'
      }
      format.xlsx {
        query = BonusElementItem.query(query_params, sort_column, sort_direction)
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        bonus_element_item_export_number = Rails.cache.fetch('bonus_element_item_export_number', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+bonus_element_item_export_number.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('bonus_element_item_export_number', bonus_element_item_export_number + 1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateBonusElementMonthItemsTableJob.perform_later(query_ids:  query.ids, query_model: 'BonusElementItem', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  # GET /bonus_element_items/1
  # def show
  #   render json: @bonus_element_item
  # end

  # GET /bonus_element_items/options
  def options
    render json: BonusElementItem.options(options_params)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bonus_element_item
      @bonus_element_item = BonusElementItem.find(params[:id])
    end

    def query_params
      params.permit(:float_salary_month_entry_id, :employee_id, :employee_name, location_ids: [], department_ids: [], position_ids: [])
    end

    def options_params
      params.permit(:float_salary_month_entry_id)
    end
end
