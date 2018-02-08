class WorkExperencesController < ApplicationController
  include WorkExperenceHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper
  before_action :set_profile, except: [:index, :columns, :options]
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department: Department.where.not(id: 1),
        location: Location.where.not(id: [32])
    }
  end

  def columns
    render json: WorkExperence.statement_columns
  end

  def index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    query = query_latest(query) if params[:latest]
    query = query.order_by(sort_column , sort_direction)
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
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: WorkExperence.statement_columns_base, options: JSON.parse(WorkExperence.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index_by_user
    authorize WorkExperence unless entry_from_mine?

    work_experences = WorkExperence.where(profile_id: @profile).as_json(include: [:creator])

    response_json work_experences
  end

  def create
    authorize WorkExperence
    @profile.work_experences.create(creator_id: current_user.id).update(params.permit(:company_organazition, :work_experience_position, :work_experience_from, :work_experience_to,:job_description,
                                                                                      :work_experience_salary, :work_experience_reason_for_leaving, :work_experience_company_phone_number,:former_head,:work_experience_email))
    response_json
  end

  def update
    authorize WorkExperence
    work_experence = @profile.work_experences.find(params[:id])
    result = work_experence.update_attributes(params.permit(:company_organazition, :work_experience_position, :work_experience_from, :work_experience_to,:job_description,
                                                            :work_experience_salary, :work_experience_reason_for_leaving, :work_experience_company_phone_number,:former_head,:work_experience_email))

    response_json result
  end

  def destroy
    authorize WorkExperence
    work_experence = @profile.work_experences.find(params[:id])
    work_experence.destroy

    response_json
  end


  private
  def query_latest(query)
    profiles = Profile.where(id: query.pluck(:profile_id)).includes(:work_experences)
    match_records = []
    profiles.each do |profile|
      match_records << profile.work_experences.order('work_experience_from desc').first
    end
    query.where(id: match_records.pluck(:id))
  end

  def send_export(query)
    work_experience_export_num = Rails.cache.fetch('work_experience_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ work_experience_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('work_experience_export_number_tag', work_experience_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def set_user
    @user = @profile.user
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def search_query
    query = WorkExperence.left_outer_joins(:profile => :user)
    %w(company_name location department).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
