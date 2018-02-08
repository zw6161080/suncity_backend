class ProvidentFundsController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper
  include MineCheckHelper
  before_action :set_profile, only: [:show, :create, :update, :can_create]
  before_action :set_user, only: [:show]
  before_action :myself?, only:[:show], if: :entry_from_mine?

  def can_create
    join_date = Time.zone.parse(params[:join_date]) rescue nil
    if join_date
      render json: ProfileService.can_create_provident_fund?(@profile.user, params[:join_date])
    else
      render json: "wrong params join_date #{params[:join_date]}", status: 422
    end
  end


  def field_options
    response_json ProvidentFund.field_options
  end

  def create_options
    response_json Config.get(:selects).select{|item| %w(nationality type_of_id).include? item}
  end

  def index
    authorize ProvidentFund
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query.order_by(sort_column , sort_direction)
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
        render json: query, root: 'data', meta: meta, each_serializer: ProvidentFundListSerializer, include: '**'
      }

      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        provident_fund_member_report_item_export_num = Rails.cache.fetch('provident_fund_member_report_item_export_number_tag', :expires_in => 24.hours) do
          1
        end
        export_id = ( "0000"+provident_fund_member_report_item_export_num.to_s).match(/\d{4}$/)[0]
        Rails.cache.write('provident_fund_member_report_item_export_number_tag', provident_fund_member_report_item_export_num + 1)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t 'statement_columns.provident_fund_member_report_items.file_name'}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: 'ProvidentFund', statement_columns: ProvidentFund.statement_columns_base('provident_fund_member_report_items'), options: JSON.parse(ProvidentFund.options('provident_fund_member_report_items').to_json), serializer: 'ProvidentFundListSerializer', my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def show
    authorize ProvidentFund unless entry_from_mine?

    response_json @profile.provident_fund.as_json(include: [:first_beneficiary, :second_beneficiary, :third_beneficiary])
  end

  def create
    authorize ProvidentFund
    ActiveRecord::Base.transaction do
      provident_fund = ProvidentFund.new(provident_fund_params)
      provident_fund.profile_id = @profile.id
      provident_fund.user_id  = @profile.user_id
      create_beneficiary(provident_fund)
      if provident_fund.save
        response_json provident_fund.id
      else
        response_json nil, error: true
      end
    end
  end

  def update
    authorize ProvidentFund
    raw_update
  end

  def update_from_profile
    authorize ProvidentFund
    raw_update
  end

  def raw_update
    provident_fund = @profile.provident_fund
    provident_fund.user_id  = @profile.user_id  if provident_fund
    ActiveRecord::Base.transaction do
      if provident_fund
        provident_fund.update(provident_fund_params) unless params[:provident_fund].empty?
        update_beneficiary(provident_fund)
        provident_fund.save
      end
      response_json
    end
  end

  private


  def search_query
    query = ProvidentFund.left_outer_joins(:first_beneficiary, :second_beneficiary, :third_beneficiary, :profile, :user)
    participation_date_begin = params[:participation_date]['begin'] rescue nil
    participation_date_end = params[:participation_date]['end'] rescue nil
    if participation_date_begin || participation_date_end
      query = query.by_participation_date(participation_date_begin, participation_date_end)
    end
    date_of_employment_begin = params[:date_of_employment]['begin'] rescue nil
    date_of_employment_end = params[:date_of_employment]['end'] rescue nil
    if date_of_employment_begin || date_of_employment_end
     query = query.by_date_of_employment(date_of_employment_begin, date_of_employment_end)
    end
    date_of_birth_begin = params[:date_of_birth]['begin'] rescue nil
    date_of_birth_end = params[:date_of_birth]['end'] rescue nil
    if date_of_birth_begin || date_of_birth_end
     query = query.by_date_of_birth(date_of_birth_begin, date_of_birth_end)
    end
    provident_fund_resignation_date_begin = params[:provident_fund_resignation_date]['begin'] rescue nil
    provident_fund_resignation_date_end = params[:provident_fund_resignation_date]['end'] rescue nil
    if provident_fund_resignation_date_begin || provident_fund_resignation_date_end
     query = query.by_provident_fund_resignation_date(provident_fund_resignation_date_begin, provident_fund_resignation_date_end)
    end

    %w(member_retirement_fund_number tax_registration icbc_account_number_mop icbc_account_number_rmb is_an_american has_permanent_resident_certificate supplier steady_growth_fund_percentage steady_fund_percentage a_fund_percentage b_fund_percentage provident_fund_resignation_reason position department chinese_name english_name empoid grade gender national place_of_birth email mobile_number address type_of_id certificate_issued_country id_number tax_number is_leave).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query

  end

  def update_beneficiary(provident_fund)
    %w(first second third).each do |item|
      update_beneficiary_single(provident_fund, item)
    end
  end

  def update_beneficiary_single(provident_fund,string)
    if provident_fund.try(:"#{string}_beneficiary")
      provident_fund.try(:"#{string}_beneficiary").update(beneficiary_params("#{string}_beneficiary")) rescue nil
    else
      beneficiary = Beneficiary.new(beneficiary_params("#{string}_beneficiary")) rescue  nil
      if beneficiary&& beneficiary.save
        provident_fund["#{string}_beneficiary_id"]= beneficiary.id
      end
    end
  end

  def create_beneficiary(provident_fund)
    %W(first second third).each do |item|
      create_single_beneficiary(provident_fund, "#{item}_beneficiary")
    end
  end

  def create_single_beneficiary(provident_fund, beneficiary_number)
    beneficiary = Beneficiary.new(beneficiary_params(beneficiary_number)) rescue  nil
    if beneficiary&& beneficiary.save
      provident_fund["#{beneficiary_number}_id"] = beneficiary.id
    end
  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end

  def set_user
    @user = @profile.user
  end

  def provident_fund_params
    params.require(:provident_fund).permit(
                                       :member_retirement_fund_number,
                                       :tax_registration,
                                       :icbc_account_number_mop,
                                       :icbc_account_number_rmb,
                                       :is_an_american,
                                       :has_permanent_resident_certificate,
                                       :supplier,
                                       :steady_growth_fund_percentage,
                                       :steady_fund_percentage,
                                       :a_fund_percentage,
                                       :b_fund_percentage,
                                       :provident_fund_resignation_date,
                                       :provident_fund_resignation_reason,
                                       :participation_date
    )
  end

  def beneficiary_params(string)
    params.require(string.to_sym).permit(
                                          :name,
                                          :certificate_type,
                                          :id_number,
                                          :relationship,
                                          :percentage,
                                          :address
    )
  end

end
