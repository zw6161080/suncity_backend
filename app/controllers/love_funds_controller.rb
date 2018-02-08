  # coding: utf-8
class LoveFundsController < ApplicationController
  include MineCheckHelper
  include SortParamsHelper
  include CurrentUserHelper
  include GenerateXlsxHelper
  include LoveFundHelper

  before_action :set_love_funds, only: [:batch_update]
  before_action :set_profile, only: [:show, :update, :can_create]
  before_action :set_user, only: [:show, :update]
  before_action :myself?, only:[:show], if: :entry_from_mine?
  # GET /love_funds


  def can_create
    join_date = Time.zone.parse(params[:join_date]) rescue nil
    if join_date
      render json: ProfileService.can_create_love_fund?(@profile.user, params[:join_date])
    else
      render json: "wrong params join_date #{params[:join_date]}", status: 422
    end
  end

  def index
    authorize LoveFund
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query
    if [:empoid, :departments, :positions, :grades, :date_of_employment, :participate, :monthly_deduction, :user].include?(sort_column)
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
      when :participate
        query = query.select_with_args("love_funds.*, CAST(((to_status = 'love_fund.enum_participate.participated' and (participate_date IS NULL or participate_date <= ?)) OR (to_status = 'love_fund.enum_participate.not_participated' and cancel_date IS NOT NULL and cancel_date > ?)) as boolean) as is_participate" , [Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_day])
                .order("is_participate #{sort_direction}" )
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      when :monthly_deduction
        query = query.select_with_args(" love_funds.*, CAST(((to_status = 'love_fund.enum_participate.participated' and (participate_date IS NULL or participate_date <= ?)) OR (to_status = 'love_fund.enum_participate.not_participated' and cancel_date IS NOT NULL and cancel_date > ?)) as boolean) as is_participate" , [Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_day])
                  .order("is_participate #{sort_direction}" )
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

  # GET /love_funds/export
  def export
    authorize LoveFund
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query
    if [:empoid, :departments, :positions, :grades, :date_of_employment, :participate, :monthly_deduction, :user].include?(sort_column)
      case sort_column
      when :empoid then
        query = query.includes(:user).order("users.empoid #{sort_direction}")
      when :user then
        query = query.includes(:user).order("users.#{select_language} #{sort_direction}")
      when :departments then
        query = query.includes(:user).order("users.department_id #{sort_direction}")
      when :positions then
        query = query.includes(:user).order("users.position_id #{sort_direction}")
      when :grades then
        query = query.includes(:user).order("users.grade #{sort_direction}")
      when :date_of_employment then
        query = query.includes(user: :profile)
                    .order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{sort_direction}")
      when :participate
        query = query.select_with_args("love_funds.*, CAST(((to_status = 'love_fund.enum_participate.participated' and (participate_date IS NULL or participate_date <= ?)) OR (to_status = 'love_fund.enum_participate.not_participated' and cancel_date IS NOT NULL and cancel_date > ?)) as boolean) as is_participate" , [Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_day])
                  .order("is_participate #{sort_direction}" )
      when :monthly_deduction
        query = query.select_with_args("love_funds.*, CAST(((to_status = 'love_fund.enum_participate.participated' and (participate_date IS NULL or participate_date <= ?)) OR (to_status = 'love_fund.enum_participate.not_participated' and cancel_date IS NOT NULL and cancel_date > ?)) as boolean) as is_participate" , [Time.zone.now.beginning_of_day, Time.zone.now.beginning_of_day])
                  .order("is_participate #{sort_direction}" )
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
      one_record[:participate]               = I18n.t('love_fund.enum_participate.'+(record.dig('is_participate') ? 'participated' : 'not_participated') )
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
      if record.dig('is_participate')
        one_record[:valid_date] =  one_record[:participate_date]
      else
        one_record[:valid_date] =  one_record[:cancel_date]
      end
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
        fields: {:employee_id         => I18n.t('love_fund.header.employee_id'),
                 :employee_name       => I18n.t('love_fund.header.employee_name'),
                 :employee_department => I18n.t('love_fund.header.employee_department'),
                 :employee_position   => I18n.t('love_fund.header.employee_position'),
                 :employee_grade      => I18n.t('love_fund.header.employee_grade'),
                 :date_of_employment  => I18n.t('love_fund.header.date_of_employment'),
                 :participate         => I18n.t('love_fund.header.participate'),
                 :valid_date          => I18n.t('love_fund.header.valid_date'),
                 :monthly_deduction   => I18n.t('love_fund.header.monthly_deduction')},
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    love_fund_export_number_tag = Rails.cache.fetch('love_fund_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+love_fund_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('love_fund_export_number_tag', love_fund_export_number_tag+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('love_fund.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  def show
    authorize LoveFund unless entry_from_mine?
    response_json @profile.love_fund
  end


  def update_from_profile
    authorize LoveFund
    raw_update
  end

  def raw_update
    love_fund = get_love_fund
    to_status = params[:to_status]
    valid_date = cal_cul_valid_date(Time.zone.parse(params[:valid_date])) rescue nil
    if love_fund.nil?
      response_json 'love_fund is null'
    elsif !%w(participated_in_the_future not_participated_in_the_future).include?(to_status) || valid_date.nil?
      response_json params.to_unsafe_hash, error: true
    else
      res = LoveFund.get_update_result(love_fund, valid_date, to_status, current_user.id)
      if res
        response_json res
      else
        response_json to_status, error: true
      end
    end
  end

  def update
    authorize LoveFund
    raw_update
  end

  # GET /love_funds/field_options
  def field_options
    response_json LoveFund.field_options
  end

  private
    def set_user
      @user = @profile.user
    end

    def set_profile
      @profile = Profile.find(params[:profile_id])
    end

    def get_love_fund
      @profile.love_fund
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_love_fund
      @love_fund = LoveFund.detail_by_id params[:id]
    end

    def set_love_funds
      @love_funds = LoveFund.detail_by_ids params[:ids]
    end

    # Only allow a trusted parameter "white list" through.
    def love_fund_params
      params.require(:love_fund).permit(*(LoveFund.create_params + %w(valid_date)))
    end

    def search_query
      query = LoveFund.includes(user: [:department, :position])

      {
          empoid:             :by_employee_no,
          departments:        :by_department_id,
          positions:          :by_position_id,
          grades:             :by_employee_grade,
          participate:        :by_participate,
          monthly_deduction:  :by_monthly_deduction
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
      query
    end
end
