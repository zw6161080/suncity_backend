class CardProfilesController < ApplicationController
  include GenerateXlsxHelper
  include CardProfileHelper
  include MineCheckHelper

  before_action :set_user, only: [:current_card_profile_by_user]
  before_action :myself?, only:[:current_card_profile_by_user], if: :entry_from_mine?

  def index
    authorize CardProfile
    profiles = search_query.select(CardProfile.columns.map(&:name)-['created_at', 'updated_at', 'comment', 'original_user', 'date_to_stamp', 'date_to_submit_certificate'])
    profiles = profiles.page(params[:page]).per(20)
    meta = {
        total_count: profiles.total_count,
        current_page: profiles.current_page,
        total_pages: profiles.total_pages,
        all_profile_count: CardProfile.count,
        applying_count:   CardProfile.where(status: "applying").count,
        cancled_count:    CardProfile.where(status: "canceled").count,
        getvisa_count:    CardProfile.where(status: "getvisa").count,
        fingermold_count: CardProfile.where(status: "fingermold").count

    }
    response_json profiles,meta:meta
  end

  def translate
    authorize CardProfile
    sex = Config.get('card_profile_field_selects')['gender']['options']
    status = Config.get('card_profile_field_selects')['status']['options']
    allocation_company = Config.get('card_profile_field_selects')['allocation_company']['options']
    report_salary_unit = Config.get('card_profile_field_selects')['report_salary_unit']['options']
    labor_company = Config.get('card_profile_field_selects')['labor_company']['options']
    new_or_renew = Config.get('card_profile_field_selects')['new_or_renew']['options']
    certificate_type = Config.get('card_profile_field_selects')['certificate_type']['options']
    nation = Config.get('selects')['nationality']['options']
     data = {
        sex: sex,
        status: status,
        allocation_company: allocation_company,
        report_salary_unit: report_salary_unit,
        labor_company: labor_company,
        new_or_renew: new_or_renew,
        certificate_type: certificate_type,
        nation: nation
    }
    response_json data
  end

  def show
    authorize CardProfile
    params.require(:id)
    profile = CardProfile.find(params[:id])
    root_information = {}

    if profile.empoid != nil
      user = User.where(empoid: profile.empoid).first
      data = user.profile.data
      nick_name = user.profile.data['personal_information']['field_values']['nick_name'] rescue nil
      root_information = {
        chinese_name: user.chinese_name,
        english_name: user.english_name,
        nick_name: nick_name,
        empoid: profile.empoid,
        nation: profile.nation,
        photo_id: profile.photo_id,
        entry_date: profile.entry_date,
        status: profile.status,
        department: Department.find(data['position_information']['field_values']['department']).as_json,
        position: Position.find(data['position_information']['field_values']['position']).as_json,
        position_id: data['position_information']['field_values']['position'],
        mobile_number: data['personal_information']['field_values']['mobile_number'],
      }
    end

    employ_information =  {
        empo_chinese_name: profile.empo_chinese_name,
        empo_english_name: profile.empo_english_name,
        sex:               profile.sex,
        status:            profile.status }

    quota_information = {
        approved_job_name:       profile.approved_job_name ,
        approved_job_number:     profile.approved_job_number ,
        allocation_company:      profile.allocation_company ,
        allocation_valid_date:   profile.allocation_valid_date ,
        approval_id:             profile.approval_id ,
        new_approval_valid_date: profile.new_approval_valid_date,
        report_salary_count:     profile.report_salary_count,
        report_salary_unit:      profile.report_salary_unit,
        labor_company:           profile.labor_company,
        date_to_submit_data:     profile.date_to_submit_data ,
        new_or_renew:            profile.new_or_renew }

    certificate_information = {
        certificate_type:        profile.certificate_type ,
        certificate_id:          profile.certificate_id ,
        certificate_valid_date:  profile.certificate_valid_date ,
        date_to_submit_certificate: profile.date_to_submit_certificate }

    street_paper_information = {
        date_to_stamp:             profile.date_to_stamp ,
        date_to_submit_fingermold: profile.date_to_submit_fingermold ,
        date_to_get_card:          profile.date_to_get_card }

    card_information = {
        card_id:          profile.card_id ,
        card_valid_date:  profile.card_valid_date,
        cancel_date:      profile.cancel_date,
        original_user:    profile.original_user }

    card_attachment_information ={
        files: profile.card_attachments.as_json
    }
    card_history_information = {
        rows:  profile.card_histories.order('updated_at desc').as_json
    }

    comment_information = {comment: profile.comment }

    record_information = {
        records: profile.card_records.order('created_at desc').as_json(include: :current_user)
    }

    data={'id'=> params[:id],
          'head'=> root_information,
          'employ_information'=> employ_information,
          'quota_information'=> quota_information,
          'certificate_information'=> certificate_information,
          'street_paper_information'=> street_paper_information,
          'card_information'=> card_information,
          'card_attachment_information'=> card_attachment_information,
          'card_history_information'=> card_history_information,
          'comment_information'=> comment_information,
          'record_information'=> record_information
    }
    response_json data
  end

  def create
    authorize CardProfile
    profile = nil
    ActiveRecord::Base.transaction do
      paramsn = params.permit(get_arr,
                              :date_to_submit_data,
                              :date_to_submit_certificate,
                              :date_to_stamp,
                              :date_to_submit_fingermold,
                              :card_id,
                              :cancel_date,
                              :original_user,
                              :comment,)
      profile = CardProfile.create(paramsn)
      if params[:card_attachments]
        params[:card_attachments].each do |attend_attachment|
          profile.card_attachments.create(attend_attachment.permit(:attachment_id, :file_name, :category, :comment, ).update(card_profile_id: profile.id, operator_id: current_user.id))
        end
      end
      if params[:card_histories]
        params[:card_histories].each do |history|
          history.require(:certificate_valid_date)
          historyn = history.permit(:certificate_valid_date,
                                    :new_approval_valid_date,
                                    :new_or_renew,
                                    :date_to_get_card,
                                    :card_valid_date )
          CardHistory.create(historyn).update(card_profile_id: profile.id)
        end
        profile.update(params[:card_histories].last.permit(:certificate_valid_date,
                                                                     :new_approval_valid_date,
                                                                     :new_or_renew,
                                                                     :date_to_get_card,
                                                                     :card_valid_date ))
      end
      number = CardProfile.where(approved_job_name: paramsn[:approved_job_name],
                                 approved_job_number: paramsn[:approved_job_number],
                                 status: 'fingermold').count
      EmpoCard.where(approved_job_name: profile.approved_job_name,
                     approved_job_number: profile.approved_job_number ).update_all(used_number: number )
      CardRecord.create({
                            key: 'create_profile',
                            current_user_id: current_user.id,
                            card_profile_id: profile.id,
                            value1: {
                                chinese_name: profile.empo_chinese_name,
                                english_name: profile.empo_english_name,
                                simple_chinese_name: nil
                            }
                        }
      )
    end
    response_json id: profile.id if profile != nil
  end

  def update
    authorize CardProfile
    initial_profile = CardProfile.find(params[:id])
    paramsn = params.permit(get_arr,
                            :date_to_submit_data,
                            :date_to_submit_certificate,
                            :date_to_stamp,
                            :date_to_submit_fingermold,
                            :card_id,
                            :cancel_date,
                            :original_user,
                            :comment,)
    profile = CardProfile.find(params[:id])
    profile.update(paramsn)
    if params[:empoid] && User.where(empoid: params[:empoid]).length > 0 && CardProfile.where(empoid: params[:empoid]).count == 0
      user = User.where(empoid:  params[:empoid]).first
      data = user.profile.data
      profile.update(
        photo_id: data['personal_information']['field_values']['photo'],
        nation: data['personal_information']['field_values']['national'],
        entry_date: data['position_information']['field_values']['date_of_employment'],
        user_id: user.id,
        empoid:user.empoid

      ) if data['personal_information']['field_values']['type_of_id'] == 'hong_kong_identity_card' ||
          data['personal_information']['field_values']['type_of_id'] == 'valid_exit_entry_permit_eep_to_hk_macau' ||
          data['personal_information']['field_values']['type_of_id'] == 'passport'
    end
    number = CardProfile.where(approved_job_name: profile.approved_job_name,
                               approved_job_number: profile.approved_job_number,
                               status: 'fingermold').count
    EmpoCard.where(approved_job_name: profile.approved_job_name,
                   approved_job_number: profile.approved_job_number).update_all(used_number: number )
    final_profile = CardProfile.find(params[:id])
    attributes = CardProfile.create_params
    attributes.each do |a|
      if initial_profile[a] != final_profile[a] && get_section_by_field(a)
        CardRecord.create(
            key: get_section_by_field(a),
            action_type: get_action_type_by_fields(initial_profile[a], final_profile[a]),
            current_user_id: current_user.id,
            field_key: a,
            file_category: nil,
            value1: final_field_value(a,initial_profile[a]),
            value2: final_field_value(a,final_profile[a]),
            value: nil,
            card_profile_id: profile.id)
      end
    end
    response_json
  end

  def matching_search
    authorize CardProfile
    text =params[:text]
    group_user_first= User.by_chinese_name(text).pluck(:empoid).compact.uniq
    group_user_second= User.by_english_name(text).pluck(:empoid).compact.uniq
    group_user_third = User.by_empoid(text).pluck(:empoid).compact.uniq
    final_group = group_user_first.concat(group_user_second).concat(group_user_third)
    res  = User.profile_to_blue_card
        .has_not_been_used_in_blue_card(CardProfile.pluck(:empoid).compact.uniq)
        .by_empoid(final_group)
        .select_show_information
    response_json  res.as_json(include: [:department, :position])

  end


  def export_xlsx
    authorize CardProfile
    fields = I18n.t 'card_profile.xlsx_title'
    profiles = search_query.select(CardProfile.columns.map(&:name)-['created_at', 'updated_at', 'comment', 'original_user', 'date_to_stamp', 'date_to_submit_certificate'])
    profiles = profiles.map do |key|
      key[:sex] = I18n.t "card_profile.sex.#{key[:sex]}" unless key[:sex].nil?
      key[:status] = I18n.t "card_profile.status.#{key[:status]}" unless key[:status].nil?
      key[:allocation_company] = I18n.t "card_profile.allocation_company.#{key[:allocation_company]}" unless key[:allocation_company].nil?
      key[:labor_company] = I18n.t "card_profile.labor_company.#{key[:labor_company]}" unless key[:labor_company].nil?
      key[:new_or_renew] = I18n.t "card_profile.new_or_renew.#{key[:new_or_renew]}" unless key[:new_or_renew].nil?
      key[:certificate_type] = I18n.t "card_profile.certificate_type.#{key[:certificate_type]}" unless key[:certificate_type].nil?
      key[:nation] = I18n.t "card_profile.nation.#{key[:nation]}" unless key[:nation].nil?
      key[:report_salary_unit] = "#{key[:report_salary_count]} #{I18n.t("card_profile.report_salary_unit.#{key[:report_salary_unit]}")}" unless key[:report_salary_unit].nil?
      ActiveModelSerializers::SerializableResource.new(key, include: '**').as_json.values.first.with_indifferent_access
    end
    card_profile_export_number_tag = Rails.cache.fetch('card_profile_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+card_profile_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('card_profile_export_number_tag', card_profile_export_number_tag+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t 'card_profile.file_name'}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateCardProfilesTableJob.perform_later(columns:  fields, query: profiles, my_attachment: my_attachment)
    render json: my_attachment

  end

  def current_card_profile_by_user
    authorize CardProfile unless entry_from_mine?
    render json: CardProfile.where(user_id: params[:user_id]).first, adapter: :attributes
  end

  private


  def set_user
    @user = User.find(params[:user_id])
  end

  def  search_query
    paramsn = params.permit(:approved_job_name, :approved_job_number, :certificate_within_60, :fingermold_within_2, :getcard_within_5,
    :profile_within_90, :allocation_within_60, :allocation_within_30, :new_approval_within_90)
    profiles = CardProfile.all
    if paramsn[:approved_job_name] && paramsn[:approved_job_number]
      profiles = CardProfile.where(status: 'fingermold',
      approved_job_name: params[:approved_job_name],
      approved_job_number: params[:approved_job_number] )
    end
    profiles = CardProfile.where("certificate_valid_date < ?", Time.zone.now + 60.day)  if paramsn[:certificate_within_60]
    profiles = CardProfile.where("date_to_submit_fingermold < ?",Time.zone.now + 2.day) if paramsn[:fingermold_within_2]
    profiles = CardProfile.where("date_to_get_card < ?",Time.zone.now + 5.day)          if paramsn[:getcard_within_5]
    profiles = CardProfile.where("card_valid_date < ?",Time.zone.now + 90.day)          if paramsn[:card_within_90]
    profiles = CardProfile.where("allocation_valid_date < ?", Time.zone.now + 60.day)   if paramsn[:allocation_within_60]
    profiles = CardProfile.where("allocation_valid_date < ?", Time.zone.now + 30.day)   if paramsn[:allocation_within_30]
    profiles = CardProfile.where("new_approval_valid_date < ?", Time.zone.now + 90.day) if paramsn[:new_approval_within_90]

    second_search_query(profiles)
  end

  def second_search_query(query)
    if params[:first_status]
      query = query.where(status: params[:first_status])
    end
    if params[:empo_chinese_name]
      query = query.where(empo_chinese_name: params[:empo_chinese_name])
    end
    if params[:empo_english_name]
      query = query.where(empo_english_name: params[:empo_english_name])
    end
    if params[:empoid]
      query = query.where(empoid: params[:empoid])
    end
    if params[:entry_date]
      query = query.where(entry_date: params[:entry_date])
    end
    if params[:sex]
      query = query.where(sex: params[:sex])
    end
    if params[:nation]
      query = query.where(nation: params[:nation])
    end
    if params[:status]
      query = query.where(status: params[:status])
    end
    if params[:approved_job_name]
      query = query.where(approved_job_name: params[:approved_job_name])
    end
    if params[:approved_job_number]
      query = query.where(approved_job_number: params[:approved_job_number])
    end
    if params[:allocation_company]
      query = query.where(allocation_company: params[:allocation_company])
    end
    if params[:allocation_valid_date]
      query = query.where(allocation_valid_date: params[:allocation_valid_date])
    end
    if params[:approval_id]
      query = query.where(approval_id: params[:approval_id])
    end
    if params[:new_approval_valid_date]
      query = query.where(new_approval_valid_date: params[:new_approval_valid_date])
    end
    if params[:report_salary_count]
      query = query.where(report_salary_count: params[:report_salary_count])
    end
    if params[:labor_company]
      query = query.where(labor_company: params[:labor_company])
    end
    if params[:date_to_submit_data]
      query = query.where(date_to_submit_data: params[:date_to_submit_data])
    end
    if params[:new_or_renew]
      query = query.where(new_or_renew: params[:new_or_renew])
    end
    if params[:certificate_type]
      query = query.where(certificate_type: params[:certificate_type])
    end
    if params[:certificate_id]
      query = query.where(certificate_id: params[:certificate_id])
    end
    if params[:certificate_valid_date]
      query = query.where(certificate_valid_date: params[:certificate_valid_date])
    end
    if params[:date_to_submit_fingermold]
      query = query.where(date_to_submit_fingermold: params[:date_to_submit_fingermold])
    end
    if params[:date_to_get_card]
      query = query.where(date_to_get_card: params[:date_to_get_card])
    end
    if params[:card_id]
      query = query.where(card_id: params[:card_id])
    end
    if params[:card_valid_date]
      query = query.where(card_id: parmas[:card_valid_date])
    end
    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      query = query.order("#{params[:sort_column]} #{params[:sort_direction]}")
      tag = true
    end
    query = query.order('created_at desc') if tag == false
    query
  end



  def get_arr
    @arr ||= [:empo_chinese_name, :empo_english_name, :sex, :status,
              :approved_job_name, :approved_job_number, :allocation_company,
              :allocation_valid_date, :approval_id,:report_salary_count,
              :report_salary_unit, :labor_company, :certificate_type, :certificate_id]
  end
end
