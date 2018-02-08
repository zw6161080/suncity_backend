class ProfessionalQualificationsController < ApplicationController
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper
  before_action :set_professional_qualification, only: [:update, :destroy]
  before_action :set_profile, only: [:index_by_user]

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department: Department.where.not(id: 1),
        location: Location.where.not(id: [32])
    }
  end

  def columns
    render json: ProfessionalQualification.statement_columns
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
        file_name = "#{I18n.t self.controller_name + '.file_name'}#{Time.zone.now.strftime('%Y%m%d-%H%M%s')}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: ProfessionalQualification.statement_columns_base, options: JSON.parse(ProfessionalQualification.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index_by_user
    render json: @profile.professional_qualifications.order(issue_date: :desc), root: 'data'
  end

  def create
    @professional_qualification = ProfessionalQualification.new(professional_qualification_params)

    if @professional_qualification.save
      render json: @professional_qualification, status: :created, location: @professional_qualification
    else
      render json: @professional_qualification.errors, status: :unprocessable_entity
    end
  end

  def update
    if @professional_qualification.update(professional_qualification_params)
      render json: @professional_qualification
    else
      render json: @professional_qualification.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @professional_qualification.destroy
    render json: { destroy: true }
  end

  private
  def query_latest(query)
    profiles = Profile.where(id: query.pluck(:profile_id)).includes(:professional_qualifications)
    match_records = []
    profiles.each do |profile|
      match_records << profile.professional_qualifications.order('issue_date desc').first
    end
    query.where(id: match_records.pluck(:id))
  end
  def set_professional_qualification
    @professional_qualification = ProfessionalQualification.find(params[:id])
  end

  def professional_qualification_params
    params.require(:professional_certificate)
    params.require(:profile_id)
    params.require(:orgnaization)
    params.require(:issue_date)
    params.permit(:profile_id, :professional_certificate, :orgnaization, :issue_date)
  end

  def set_user
    @user = @profile.user
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def search_query
    query = ProfessionalQualification.left_outer_joins(:profile => :user)
    %w(company_name location department).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
