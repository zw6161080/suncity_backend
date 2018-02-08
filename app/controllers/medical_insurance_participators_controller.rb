# coding: utf-8
class MedicalInsuranceParticipatorsController < ApplicationController

  include SortParamsHelper
  include GenerateXlsxHelper
  include MedicalInsuranceParticipatorHelper
  include MineCheckHelper

  before_action :set_medical_insurance_participators, only: [:batch_update]
  before_action :set_profile, only: [:update, :show, :can_create]
  before_action :set_user, only: [:show]
  before_action :myself?, only:[:show], if: :entry_from_mine?

  def  can_create
    join_date = Time.zone.parse(params[:join_date]) rescue nil
    if join_date
      render json: ProfileService.can_create_medical_insurance_participator?(@profile.user, params[:join_date])
    else
      render json: "wrong params join_date #{params[:join_date]}", status: 422
    end
  end

  # GET /medical_insurance_participators
  def index
    authorize MedicalInsuranceParticipator
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query
    if [:empoid, :departments, :positions, :grades, :date_of_employment, :medical_templates, :effective_date, :user].include?(sort_column)
      case sort_column
      when :user
        query = query.includes(:user)
                      .order("users.#{select_language} #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :empoid then
          query = query.includes(:user)
                      .order("users.empoid #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :departments then
          query = query.includes(:user)
                      .order("users.department_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :positions then
          query = query.includes(:user)
                      .order("users.position_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :grades then
          query = query.includes(:user)
                      .order("users.grade #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :date_of_employment then
          query = query.includes(user: :profile)
                      .order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
      when :medical_templates then
            query = query.joins(:user)
                      .select("*, case participate when 'medical_insurance_paticipator.enum_participate.participated' then users.grade when 'medical_insurance_paticipator.enum_participate.not_participated' then 0 end gradeaa")
                      .order("gradeaa #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
      when :effective_date
        query = query.select("*, case participate when 'medical_insurance_paticipator.enum_participate.participated' then participate_date when 'medical_insurance_paticipator.enum_participate.not_participated' then cancel_date end effective_date").order("effective_date #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      end
    else
      query = query
                  .order(sort_column => sort_direction)
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
    end
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    data = query.map do |record|
      record.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # GET /medical_insurance_participators/export
  def export
    authorize MedicalInsuranceParticipator
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query
    if [:empoid, :departments, :positions, :grades, :date_of_employment, :medical_templates, :effective_date, :user].include?(sort_column)
      case sort_column
      when :user
        query = query.includes(:user).order("users.#{select_language} #{sort_direction}")
        when :empoid then
          query = query.includes(:user).order("users.empoid #{sort_direction}")
        when :departments then
          query = query.includes(:user).order("users.department_id #{sort_direction}")
        when :positions then
          query = query.includes(:user).order("users.position_id #{sort_direction}")
        when :grades then
          query = query.includes(:user).order("users.grade #{sort_direction}")
        when :date_of_employment then
          query = query.includes(user: :profile)
                      .order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{sort_direction}")
        when :medical_templates then
          query = query.includes(:user).order("users.grade #{sort_direction}")
      when :effective_date
        query = query.select("*, case participate when 'medical_insurance_paticipator.enum_participate.participated' then participate_date when 'medical_insurance_paticipator.enum_participate.not_participated' then cancel_date end effective_date").order("effective_date #{sort_direction}")

      end
    else
      query = query.order(sort_column => sort_direction)
    end
    data = query.map do |record|
      record.get_json_data
    end
    # 数据筛选
    selected_data = data.map do |record|
      one_record = {}
      one_record[:employee_id]               = record.dig 'user.empoid'
      one_record[:employee_grade]            = record.dig 'user.grade'
      one_record[:date_of_employment]        = User.find(record['user_id']).profile.data['position_information']['field_values']['date_of_employment']
      one_record[:participate]               = I18n.t("medical_insurance_participator.enum_participate.#{record.dig 'participate'}")
      if record.dig('participate_date')
        one_record[:participate_date]        = record.dig('participate_date').strftime('%Y/%m/%d')
      else
        one_record[:participate_date]        = ' '
      end
      if record.dig('cancel_date')
        one_record[:cancel_date]             = record.dig('cancel_date').strftime('%Y/%m/%d')
      else
        one_record[:cancel_date]             = ' '
      end
      if record.dig('participate') == 'participated'
        one_record[:valid_date] =  one_record[:participate_date]
      else
        one_record[:valid_date] =  one_record[:cancel_date]
      end
      one_record[:medical_template]  = record.dig( 'medical_template')&.send("#{select_language}")
      one_record[:monthly_deduction]         = record.dig 'monthly_deduction'
      if I18n.locale==:en
        one_record[:employee_name]       = record.dig 'user.english_name'
        one_record[:employee_department] = record.dig 'user.department.english_name'
        one_record[:employee_position]   = record.dig 'user.position.english_name'
      elsif I18n.locale==:'zh-CN'
        one_record[:employee_name]       = record.dig 'user.simple_chinese_name'
        one_record[:employee_department] = record.dig 'user.department.simple_chinese_name'
        one_record[:employee_position]   = record.dig 'user.position.simple_chinese_name'
      else
        one_record[:employee_name]       = record.dig 'user.chinese_name'
        one_record[:employee_department] = record.dig 'user.department.chinese_name'
        one_record[:employee_position]   = record.dig 'user.position.chinese_name'
      end
      one_record
    end
    # 生成Excel
    xlsx_data = {
        fields: {:employee_id         => I18n.t('medical_insurance_participator.header.employee_id'),
                 :employee_name       => I18n.t('medical_insurance_participator.header.employee_name'),
                 :employee_department => I18n.t('medical_insurance_participator.header.employee_department'),
                 :employee_position   => I18n.t('medical_insurance_participator.header.employee_position'),
                 :employee_grade      => I18n.t('medical_insurance_participator.header.employee_grade'),
                 :date_of_employment  => I18n.t('medical_insurance_participator.header.date_of_employment'),
                 :participate         => I18n.t('medical_insurance_participator.header.participate'),
                 :valid_date          => I18n.t('medical_insurance_participator.header.valid_date'),
                 :medical_template    => I18n.t('medical_insurance_participator.header.medical_template'),
                 :monthly_deduction   => I18n.t('medical_insurance_participator.header.monthly_deduction')},
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    over_time_export_num = Rails.cache.fetch('over_time_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('over_time_export_number_tag', over_time_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('medical_insurance_participator.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # GET /medical_insurance_participators/1
  def show
    authorize MedicalInsuranceParticipator unless entry_from_mine?

    medical_insurance_participator = @profile.medical_insurance_participator
    medical_template = nil
    now_year_medical_information = nil
    if medical_insurance_participator  && medical_insurance_participator['participate'] == 'participated'
        medical_template = MedicalTemplate.find(medical_insurance_participator.medical_template_id) rescue nil
        now_year_medical_information = get_now_year_medical_information(medical_template)
    end
    response_json ({
        medical_insurance_participator: medical_insurance_participator,
        medical_template: medical_template ,
        now_year_medical_information: now_year_medical_information ,
        medical_reimbursements: MedicalReimbursement.where(user_id: @profile.user_id).order('reimbursement_year desc, apply_date desc').as_json(include: [:tracker, :medical_template,  :attachment_items, medical_item: {include: :medical_item_template}])
    })
  end

  # PATCH/PUT /medical_insurance_participators/1

  def update
    authorize MedicalInsuranceParticipator
    raw_update
  end

  def raw_update
    medical_insurance_participator = @profile.medical_insurance_participator
    medical_insurance_participator = if medical_insurance_participator
                                       medical_insurance_participator.update_with_params(medical_insurance_participator_params,current_user.id)
                                     else
                                       MedicalInsuranceParticipator.create_with_params(medical_insurance_participator_params, @profile, current_user.id)
                                     end
    if medical_insurance_participator
      response_json medical_insurance_participator
    else
      response_json  medical_insurance_participator_params, status: :unprocessable_entity
    end
  end


  def update_from_profile
    authorize MedicalInsuranceParticipator
    raw_update
  end


  # PATCH/PUT /medical_insurance_participators/batch_update
  def batch_update
    i = 0
    @medical_insurance_participators[:data].each do |item|
      if item.update_with_params(medical_insurance_participator_params,current_user.id)
        i += 1
      end
    end
    response_json i
  end

  # GET /medical_insurance_participators/field_options
  def field_options
    response_json MedicalInsuranceParticipator.field_options
  end

  private
    def set_user
      @user = @profile.user
    end
    def set_profile
      @profile = Profile.find(params[:profile_id])
    end

    def get_medical_template(profile = nil)
      get_medical_template_up_to_grade(profile || @profile)
    end



    def  get_medical_template_id(create_params, profile = nil)
      if create_params[:participate] == 'participated'
        get_medical_template(profile)
      else
        nil
      end
    end

    def get_now_year_medical_information(medical_template)
      if medical_template
         month, day = medical_template.balance_date.month, medical_template.balance_date.day
         now_year_balance_day = Time.zone.local(Time.zone.now.year, month, day)
         now_day = Time.zone.now.beginning_of_day
         reimbursement_year =if  now_day  > now_year_balance_day
                              now_day.year
                             else
                               now_day.year - 1
                             end
        medical_template.medical_items.map do |item|
          item =item.as_json.merge!(
              has_used_reimbursement_times: @profile.user.medical_reimbursements.where(reimbursement_year: reimbursement_year, medical_item_id: item[:id] ).count,
              has_used_reimbursement_amount: @profile.user.medical_reimbursements.where(reimbursement_year: reimbursement_year, medical_item_id: item[:id] ).sum(:reimbursement_amount)
          )
          left_reimbursement_times = item['reimbursement_times'].to_i - item[:has_used_reimbursement_times]
          left_reimbursement_amount = BigDecimal.new(item['reimbursement_amount'].to_s) - BigDecimal.new(item[:has_used_reimbursement_amount])
          item.merge!(
              left_reimbursement_times: left_reimbursement_times < 0 ? 0 : left_reimbursement_times,
              left_reimbursement_amount: left_reimbursement_amount < 0 ? 0 : left_reimbursement_amount
          )
        end
      else
        nil
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_medical_insurance_participator
      @medical_insurance_participator = MedicalInsuranceParticipator.detail_by_id params[:id]
    end

    def set_medical_insurance_participators
      @medical_insurance_participators = MedicalInsuranceParticipator.detail_by_ids params[:ids]
    end

    # Only allow a trusted parameter "white list" through.
    def medical_insurance_participator_params
      params.require(:medical_insurance_participator).permit(*MedicalInsuranceParticipator.create_params)
    end

    def search_query
      query = MedicalInsuranceParticipator.includes(user: [:department, :position])
      {
          empoid:              :by_employee_no,
          departments:         :by_department_id,
          positions:           :by_position_id,
          grades:              :by_employee_grade,
          participate:         :by_participate,
          medical_templates:   :by_medical_template_id,
          monthly_deduction:   :by_monthly_deduction
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end

      if params[:user]
        if params[:user] =~ /^[A-Za-z]/
          query = query.where(users: {english_name: params[:user]})
        else
          query = query.where(users: {chinese_name: params[:user]})
        end
      end

      if params[:date_of_employment]
        range = params[:date_of_employment][:begin]..params[:date_of_employment][:end]
        ids = []
        query.each do |record|
          unless range.include?(User.find(record['user_id']).profile.data['position_information']['field_values']['date_of_employment'])
            ids += [record.id]
          end
        end
        query = query.where.not(id: ids)
      end

      if params[:participate_date]
        if params[:participate_date][:begin].present? && params[:participate_date][:end].present?
          query = query.where(participate_date: Time.zone.parse(params[:participate_date][:begin])..Time.zone.parse(params[:participate_date][:end]))
        elsif params[:participate_date][:begin].present? && params[:participate_date][:end].blank?
          query = query.where("participate_date >= ?", Time.zone.parse(params[:participate_date][:begin]))
        elsif params[:participate_date][:begin].blank? && params[:participate_date][:end].present?
          query = query.where("participate_date <= ?", Time.zone.parse(params[:participate_date][:end]))
        end
      end

      if params[:cancel_date]
        if params[:cancel_date][:begin].present? && params[:cancel_date][:end].present?
          query = query.where(cancel_date: Time.zone.parse(params[:cancel_date][:begin])..Time.zone.parse(params[:cancel_date][:end]))
        elsif params[:cancel_date][:begin].present? && params[:cancel_date][:end].blank?
          query = query.where("cancel_date >= ?", Time.zone.parse(params[:cancel_date][:begin]))
        elsif params[:cancel_date][:begin].blank? && params[:cancel_date][:end].present?
          query = query.where("cancel_date <= ?", Time.zone.parse(params[:cancel_date][:end]))
        end
      end

      if params[:effective_date]
        if params[:effective_date][:begin].present? && params[:effective_date][:end].present?
          query =  query.where("case participate when 'medical_insurance_paticipator.enum_participate.participated' then participate_date when 'medical_insurance_paticipator.enum_participate.not_participated' then cancel_date end >= ? AND case participate when 'medical_insurance_paticipator.enum_participate.participated' then participate_date when 'medical_insurance_paticipator.enum_participate.not_participated' then cancel_date end <= ? ", Time.zone.parse(params[:effective_date][:begin]), Time.zone.parse(params[:effective_date][:end]))
        elsif params[:effective_date][:begin].present? && params[:effective_date][:end].blank?
          query = query.where("case participate when 'medical_insurance_paticipator.enum_participate.participated' then participate_date when 'medical_insurance_paticipator.enum_participate.not_participated' then cancel_date end <= ? ", Time.zone.parse(params[:effective_date][:begin]))
        elsif params[:effective_date][:begin].blank? && params[:effective_date][:end].present?
          query = query.where("case participate when 'medical_insurance_paticipator.enum_participate.participated' then participate_date when 'medical_insurance_paticipator.enum_participate.not_participated' then cancel_date end >= ? ", Time.zone.parse(params[:effective_date][:end]))
        end
      end
      query
    end

end
