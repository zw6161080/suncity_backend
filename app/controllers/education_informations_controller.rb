class EducationInformationsController < ApplicationController
  include EducationInformationHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper
  before_action :set_profile, except: [:columns, :options, :index]
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?

  def columns
    render json: EducationInformation.statement_columns
  end

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department: Department.where.not(id: 1),
        location: Location.where.not(id: [32])
    }
  end

  def index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    query = query.where(highest: true) if params[:highest]
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
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: EducationInformation.statement_columns_base, options: JSON.parse(EducationInformation.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index_by_user
    authorize EducationInformation unless entry_from_mine?

    education_informations = EducationInformation.where(profile_id: @profile).as_json(include: [:creator])

    render json: education_informations, root: 'data'
  end

  def create
    authorize EducationInformation
    ActiveRecord::Base.transaction do
      if params[:highest]
        @profile.education_informations.each { |r| r.update(highest: false )}
      end
      @profile.education_informations.create(education_information_params.merge({ creator_id: current_user.id }))
      response_json
    end
  end

  def update
    authorize EducationInformation
    ActiveRecord::Base.transaction do
      if params[:highest]
        @profile.education_informations.each { |r| r.update(highest: false )}
      end
      education_information = @profile.education_informations.find(params[:id])
      result = education_information.update_attributes(education_information_params)

      response_json result
    end

  end

  def destroy
    authorize EducationInformation
    education_information = @profile.education_informations.find(params[:id])
    education_information.destroy

    response_json
  end


  private
  def education_information_params
    params.require(:highest)
    params.require(:from_mm_yyyy)
    params.require(:to_mm_yyyy)
    params.require(:college_university)
    params.require(:educational_department)
    params.require(:graduate_level)
    # params.require(:diploma_degree_attained)
    # params.require(:certificate_issue_date)
    params.require(:graduated)
    params.permit(
        :from_mm_yyyy,
        :to_mm_yyyy,
        :college_university,
        :educational_department,
        :graduate_level,
        :graduated,
        :diploma_degree_attained,
        :certificate_issue_date,
        :highest
    )
  end

  def send_export(query)
    education_information_export_num = Rails.cache.fetch('education_information_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ education_information_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('education_information_export_number_tag', education_information_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end


  def set_user
    @user = @profile.user
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def search_query
    query = EducationInformation.left_outer_joins(:profile => :user)
    %w(company_name location department).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
