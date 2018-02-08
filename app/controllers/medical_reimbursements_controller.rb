class MedicalReimbursementsController < ApplicationController

  include SortParamsHelper
  include CurrentUserHelper
  include GenerateXlsxHelper

  before_action :set_medical_reimbursement, only: [:show, :update, :destroy]



  # GET /medical_reimbursements
  def index
    authorize MedicalReimbursement
    sort_column = sort_column_sym(params[:sort_column], :default_order)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:empoid, :departments, :positions, :insurance_type, :medical_item, :trackers, :medical_templates, :user].include?(sort_column)
      case sort_column
      when :user then
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
      when :insurance_type then
        query = query.includes(:medical_template)
                    .order("medical_templates.insurance_type #{sort_direction}")
                    .page
                    .page(params.fetch(:page, 1))
                    .per(20)
      when :medical_item then
        query = query
                    .order("medical_item_id #{sort_direction}")
                    .page
                    .page(params.fetch(:page, 1))
                    .per(20)
      when :trackers then
        query = query
                    .order("tracker_id #{sort_direction}")
                    .page
                    .page(params.fetch(:page, 1))
                    .per(20)
      when :medical_templates
        query = query
                  .order("medical_template_id #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      end
    else
      if sort_column == :default_order
        query = query.joins(:user)
                  .order('apply_date desc, users.empoid asc')
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      else
        query = query
                  .order(sort_column => sort_direction)
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      end
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

  # GET /medical_reimbursements/export
  def export
    authorize MedicalReimbursement
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], :default_order)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:empoid, :departments, :positions, :insurance_type, :medical_item, :trackers, :medical_templates, :user].include?(sort_column)
      case sort_column
      when :user then
        query = query.includes(:user).order("users.#{select_language} #{sort_direction}")
        when :empoid then
          query = query.includes(:user).order("users.empoid #{sort_direction}")
        when :departments then
          query = query.includes(:user).order("users.department_id #{sort_direction}")
        when :positions then
          query = query.includes(:user).order("users.position_id #{sort_direction}")
        when :insurance_type then
          query = query.includes(:medical_template).order("medical_templates.insurance_type #{sort_direction}")
        when :medical_item then
          query = query.order("medical_item_id #{sort_direction}")
        when :trackers then
          query = query.order("tracker_id #{sort_direction}")
        when :medical_templates then
          query = query.order("medical_template_id #{sort_direction}")
      end
    else
      if sort_column == :default_order
        query = query.joins(:user).order('apply_date desc, users.empoid asc')

      else
        query = query.order(sort_column => sort_direction)

      end
    end
    data = query.map do |record|
      record.get_json_data
    end
    # 数据筛选
    selected_data = data.map do |record|
      one_record = {}
      one_record[:reimbursement_year]    = record.dig 'reimbursement_year'
      one_record[:employee_id]           = record.dig 'user.empoid'
      one_record[:apply_date]            = record.dig('apply_date').strftime('%Y/%m/%d')
      one_record[:insurance_type]        = I18n.t('medical_template.enum_insurance_type.'+record.dig('insurance_type'))
      one_record[:document_number]       = record.dig 'document_number'
      one_record[:document_amount]       = record.dig('document_amount').to_s+' MOP'
      one_record[:reimbursement_amount]  = record.dig('reimbursement_amount').to_s+' MOP'
      one_record[:track_date]            = record.dig('track_date').strftime('%Y/%m/%d')
      if I18n.locale==:en
        one_record[:employee_name]       = record.dig 'user.english_name'
        one_record[:employee_department] = record.dig 'user.department.english_name'
        one_record[:employee_position]   = record.dig 'user.position.english_name'
        one_record[:medical_item]        = record.dig('medical_item_template').english_name
        one_record[:tracker]             = record.dig('tracker').english_name
      elsif I18n.locale==:'zh-CN'
        one_record[:employee_name]       = record.dig 'user.simple_chinese_name'
        one_record[:employee_department] = record.dig 'user.department.simple_chinese_name'
        one_record[:employee_position]   = record.dig 'user.position.simple_chinese_name'
        one_record[:medical_item]        = record.dig('medical_item_template').simple_chinese_name
        one_record[:tracker]             = record.dig('tracker').simple_chinese_name
      else
        one_record[:employee_name]       = record.dig 'user.chinese_name'
        one_record[:employee_department] = record.dig 'user.department.chinese_name'
        one_record[:employee_position]   = record.dig 'user.position.chinese_name'
        one_record[:medical_item]        = record.dig('medical_item_template').chinese_name
        one_record[:tracker]             = record.dig('tracker').chinese_name
      end
      one_record
    end
    # 生成Excel
    xlsx_data = {
        fields: {:reimbursement_year   => I18n.t('medical_reimbursement.header.reimbursement_year'),
                 :employee_id          => I18n.t('medical_reimbursement.header.employee_id'),
                 :employee_name        => I18n.t('medical_reimbursement.header.employee_name'),
                 :employee_department  => I18n.t('medical_reimbursement.header.employee_department'),
                 :employee_position    => I18n.t('medical_reimbursement.header.employee_position'),
                 :apply_date           => I18n.t('medical_reimbursement.header.apply_date'),
                 :insurance_type       => I18n.t('medical_reimbursement.header.insurance_type'),
                 :medical_item         => I18n.t('medical_reimbursement.header.medical_item'),
                 :document_number      => I18n.t('medical_reimbursement.header.document_number'),
                 :document_amount      => I18n.t('medical_reimbursement.header.document_amount'),
                 :reimbursement_amount => I18n.t('medical_reimbursement.header.reimbursement_amount'),
                 :tracker              => I18n.t('medical_reimbursement.header.tracker'),
                 :track_date           => I18n.t('medical_reimbursement.header.track_date')},
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    medical_reimbursement_export_number_tag = Rails.cache.fetch('medical_reimbursement_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+medical_reimbursement_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('medical_reimbursement_export_number_tag', medical_reimbursement_export_number_tag+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('medical_reimbursement.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # # GET /medical_reimbursements/1
  # def show
  #   data = @medical_reimbursement.as_json(include: [:user, :medical_item, :attachment_items])
  #   data['medical_item_template'] = MedicalItemTemplate.find(data['medical_item']['medical_item_template_id'])
  #   response_json data
  # end

  # GET /medical_reimbursements/show_medical_items
  def show_medical_items
    record = MedicalInsuranceParticipator.find_by_user_id(params[:id])
    if record.participate=='participated'
      response_json MedicalTemplate.find(record.medical_template_id).medical_items.as_json(include: :medical_item_template)
    else
      response_json []
    end
  end

  # GET /medical_reimbursements/if_participate_medical_insurance
  def if_participate_medical_insurance
    response_json MedicalInsuranceParticipator.find_by_user_id(params[:id]).participate
  end

  def download
    authorize MedicalReimbursement
    attachment = Attachment.find params[:id]
    headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(attachment.seaweed_hash)
    render body: nil
  end


  def download_from_profile
    authorize MedicalReimbursement
    attachment = Attachment.find params[:id]
    headers['X-Accel-Redirect'] = Attachment.x_accel_url_with_hash(attachment.seaweed_hash)
    render body: nil
  end


  # POST /medical_reimbursements
  def create_from_profile
    authorize MedicalReimbursement
    raw_create
  end

  def raw_create
    #获取报销项目
    medical_item = MedicalItem.find(params[:medical_reimbursement][:medical_item_id])
    if BigDecimal(params[:medical_reimbursement][:reimbursement_amount]) >  medical_item.reimbursement_amount
      render json: {reimbursement_amount: medical_item.reimbursement_amount}, status: 202

    else
      user = User.find(medical_reimbursement_params[:user_id])
      leave_this_month_before = ProfileService.resigned_date(user) <=  Time.zone.now.end_of_month.beginning_of_day rescue false
      if leave_this_month_before
        render json: {user: user, resigned_date: ProfileService.resigned_date(user)}, status: 202
        return
      end

      # 获取 medical_template_id
      medical_template_id = MedicalInsuranceParticipator.find_by_user_id(medical_reimbursement_params[:user_id]).medical_template_id
      # 获取 年份 字段
      balance_date = MedicalTemplate.find(medical_template_id).balance_date
      apply_date = Time.zone.parse(medical_reimbursement_params[:apply_date])
      formed_balance_date = Date.new(apply_date.year, balance_date.month, balance_date.day)
      if apply_date <= formed_balance_date
        reimbursement_year = apply_date.year - 1
      else
        reimbursement_year = apply_date.year
      end
      # 创建记录
      medical_reimbursement = MedicalReimbursement.create(
        medical_reimbursement_params.as_json.merge(
          reimbursement_year: reimbursement_year,
          medical_template_id: medical_template_id,
          tracker_id: current_user.id,
          track_date: DateTime.now.strftime('%Y/%m/%d')
        )
      )
      if params['attachment_items'].to_a != []
        params['attachment_items'].as_json.each do |param|
          medical_reimbursement.attachment_items.create(param.as_json.merge(creator_id: current_user.id))
        end
      end
      response_json medical_reimbursement
    end

  end
  def create
    authorize MedicalReimbursement
    raw_create

  end


  def update_from_profile
    authorize MedicalReimbursement
    raw_update
  end

  def raw_update
    if @medical_reimbursement.update(
      medical_reimbursement_params.as_json.merge(
        tracker_id: current_user.id,
        track_date: DateTime.now.strftime('%Y/%m/%d')
      )
    )
      if params['attachment_items'].to_a != []
        @medical_reimbursement.attachment_items.clear
        params['attachment_items'].as_json.each do |params|
          @medical_reimbursement.attachment_items << AttachmentItem.create(params.as_json.merge(creator_id: current_user.id))
        end
      else
        @medical_reimbursement.attachment_items.clear
      end
      response_json @medical_reimbursement.as_json(include: [:user, :medical_item, :attachment_items])
    else
      response_json @medical_reimbursement.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /medical_reimbursements/1
  def update
    authorize MedicalReimbursement
    raw_update
  end

  # DELETE /medical_reimbursements/1
  def destroy
    authorize MedicalReimbursement
    @medical_reimbursement.destroy
    response_json
  end

  def destroy_from_profile
    authorize MedicalReimbursement
    @medical_reimbursement.destroy
    response_json
  end

  # GET /medical_reimbursements/field_options
  def field_options
    response_json MedicalReimbursement.field_options
  end

  # GET /medical_reimbursements/send_message
  # 获取发送内容
  def send_message
    authorize MedicalReimbursement
    response_json MedicalReimbursement.find(params[:id]).as_json(include: {user: {include: :profile}})
  end

  def query_medical_conditions
    render json: {data: MedicalReimbursement.query_medical_conditions(params[:year], params[:id], params[:user_id])}
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_medical_reimbursement
      @medical_reimbursement = MedicalReimbursement.detail_by_id params[:id]
    end

    # Only allow a trusted parameter "white list" through.
    def medical_reimbursement_params
      params.require(:medical_reimbursement).permit(*MedicalReimbursement.create_params)
    end

    def search_query
      query = MedicalReimbursement
                  .includes(user: [:department, :position])
                  .includes(:medical_template)
                  .includes(:medical_item)
                  .includes(:tracker)

      {
          reimbursement_year:   :by_reimbursement_year,
          empoid:               :by_employee_no,
          departments:          :by_department_id,
          positions:            :by_position_id,
          insurance_type:       :by_insurance_type,
          medical_item:         :by_medical_item_id,
          document_number:      :by_document_number,
          document_amount:      :by_document_amount,
          reimbursement_amount: :by_reimbursement_amount,
          trackers:              :by_tracker_id,
          medical_templates:    :by_medical_template_id
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

      if params[:apply_date]
        if params[:apply_date][:begin].present? && params[:apply_date][:end].present?
          query = query.where(apply_date: Time.zone.parse(params[:apply_date][:begin])..Time.zone.parse(params[:apply_date][:end]))
        elsif params[:apply_date][:begin].present? && params[:apply_date][:end].blank?
          query = query.where("apply_date >= ?", Time.zone.parse(params[:apply_date][:begin]))
        elsif params[:apply_date][:begin].blank? && params[:apply_date][:end].present?
          query = query.where("apply_date <= ?", Time.zone.parse(params[:apply_date][:end]))
        end
      end

      if params[:track_date]
        if params[:track_date][:begin].present? && params[:track_date][:end].present?
          query = query.where(track_date: Time.zone.parse(params[:track_date][:begin])..Time.zone.parse(params[:track_date][:end]))
        elsif params[:track_date][:begin].present? && params[:track_date][:end].blank?
          query = query.where("track_date >= ?", Time.zone.parse(params[:track_date][:begin]))
        elsif params[:track_date][:begin].blank? && params[:track_date][:end].present?
          query = query.where("track_date <= ?", Time.zone.parse(params[:track_date][:end]))
        end
      end
      query
    end

end
