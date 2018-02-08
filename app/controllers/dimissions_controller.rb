class DimissionsController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper

  before_action :set_dimission, only: [:show]
  before_action :set_locale

  # GET /dimissions
  def index
    authorize Dimission
    sort_column = sort_column_sym(params[:sort_column], :apply_date)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    if [ :location_id, :department_id, :position_id ].include?(sort_column)
      query = search_query.order("users.#{sort_column} #{sort_direction}")
    elsif sort_column == :employee_name
      query = search_query.order("users.#{select_language} #{sort_direction}")
    elsif sort_column == :creator_name
      query = search_query.joins(:creator).order("creators_dimissions.#{select_language} #{sort_direction}")
    elsif sort_column == :employee_no
      query = search_query.order("users.empoid #{sort_direction}")
    else
      query = search_query.order(sort_column => sort_direction)
    end

    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }

        render json: query, meta: meta, root: 'data', include: '**'
      }

      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        dimission_number_tag = Rails.cache.fetch('dimission_number_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+dimission_number_tag.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('dimission_number_tag', dimission_number_tag+1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "離職申請_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateDismissionTableJob.perform_later(query_ids:  query.ids, query_model: 'Dimission', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  # GET /dimissions/apply_options
  def apply_options
    dimission_reasons = Config.get('selects').dig 'reason_for_resignation.options'
    response_json Config.get('dimission')
                    .merge({career_history_dimission_reasons: dimission_reasons.presence || []})
  end

  # GET /dimissions/field_options
  def field_options
    response_json Dimission.field_options
  end

  # GET /dimissions/1
  def show
    authorize Dimission
    response_json @dimission.as_json(include: [
      {group: {}},
      { user: {
        include: [ :department, :position, :location ],
        methods: :career_entry_date
      }
      },
      { creator: { include: [ :department, :position, :location ] } },
      {
        dimission_follow_ups: {
          include: {
            handler: { include: [ :department, :position, :location ] }
          }
        }
      },
      {
        approval_items: {
          include: {
            user: { include: [ :department, :position, :location ] }
          }
        }
      },
      {
        attachment_items: {
          include: {
            creator: { include: [ :department, :position, :location ] }
          }
        }
      }
    ])
  end

  # POST /dimissions
  def create
    authorize Dimission
    dimission_id = Dimission.create_with_params(
      params.permit(
        *Dimission.create_params,
        resignation_reason: [],
        resignation_future_plan: [],
        termination_reason: [],
        resignation_certificate_languages: [],
      ).merge({ creator_id: current_user.id }),
      params[:follow_ups]&.map { |item| item.permit(*DimissionFollowUp.create_params) },
      params[:approval_items]&.map { |item| item.permit(*ApprovalItem.create_params) },
      params[:attachment_items]&.map { |item|
        item.permit(*AttachmentItem.create_params).merge({ creator_id: current_user.id })
      },
      reason_for_resignation: params[:reason_for_resignation_for_resignation_record],
      comment: params[:comment_for_resignation_record]
    )

    dimission = Dimission.find(dimission_id)
    Message.add_task(dimission, "create_dimission", dimission['creator_id'])

    response_json dimission_id
  end

  # GET /dimissions/termination_compensation
  def termination_compensation
    params.require(:user_id)
    params.require(:is_reasonable_termination)
    params.require(:last_work_date)

    response_json Dimission.termination_compensation(
      User.find(params[:user_id]),
      params[:is_reason_termination].to_s == 'true',
      params[:last_work_date].to_date
    )
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_dimission
    @dimission = Dimission.detail_by_id params[:id]
  end

  def search_query
    query = Dimission.join_users_query

    apply_date_begin = params[:apply_date_begin].to_date.beginning_of_day rescue nil
    apply_date_end = params[:apply_date_end].to_date.end_of_day rescue nil
    if apply_date_begin && apply_date_end
      query = query.by_apply_date(apply_date_begin, apply_date_end)
    end

    inform_date_begin = params[:inform_date_begin].to_date.beginning_of_day rescue nil
    inform_date_end = params[:inform_date_end].to_date.end_of_day rescue nil
    if inform_date_begin && inform_date_end
      query = query.by_inform_date(inform_date_begin, inform_date_end)
    end

    last_work_date_begin = params[:last_work_date_begin].to_date.beginning_of_day rescue nil
    last_work_date_end = params[:last_work_date_end].to_date.end_of_day rescue nil
    if last_work_date_begin && last_work_date_end
      query = query.by_last_work_date(last_work_date_begin, last_work_date_end)
    end

    created_at_begin = params[:created_at_begin].to_date.beginning_of_day rescue nil
    created_at_end = params[:created_at_end].to_date.end_of_day rescue nil
    if created_at_begin && created_at_end
      query = query.by_created_at(created_at_begin, created_at_end)
    end

    final_work_date_begin = Time.zone.parse(params[:final_work_date_begin ]).beginning_of_day rescue nil
    final_work_date_end = Time.zone.parse(params[:final_work_date_end]).end_of_day rescue nil

    query = query.by_final_work_date(final_work_date_begin, final_work_date_end)

    {
      dimission_type: :by_type,
      employee_no: :by_users_employee_no,
      location_id: :by_users_location_id,
      department_id: :by_users_department_id,
      position_id: :by_users_position_id,
      employee_name: :by_users_employee_name,
      creator_name: :by_creator_name,
      group_id: :by_group_id,
      company_name: :by_company_name,
    }.each do |key, value|
      query = query.send(value, params[key]) if params[key]
    end
    query
  end
end
