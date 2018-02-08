# coding: utf-8
class ProfilesController < ApplicationController
  include MedicalInsuranceParticipatorHelper
  include LoveFundHelper
  include SalaryRecordHelper

  include WelfareRecordHelper

  include WorkExperenceHelper
  include EducationInformationHelper

  include GenerateXlsxHelper

  include FormedProfileUpdatedParamsHelper

  include FormedProfileCreatedParamsHelper
  include MineCheckHelper
  before_action :set_user, only: [:holiday_info]
  before_action :set_profile, only: [:head_title]
  before_action :get_user, only: [:show]
  before_action :myself?, only:[:show], if: :entry_from_mine?

  def check_l_p_d
    location = Location.find(params[:location_id]) rescue nil
    department = Department.find(params[:department_id]) rescue nil
    position = Position.find(params[:position_id]) rescue nil
    if (location && department && position)
      p_in_l = location.positions.exists? position
      p_in_d = department.positions.exists? position
      d_in_l = location.departments.exists? department
      render json: { result: p_in_l && p_in_d && d_in_l }
      return
    end
    render json: { result: false }
  end

  def advance_search_params_check
    query_result = User.joins(:profile)
                       .where({params['search_type'] => params[:search_data]})
                       .where("profiles.region = ?", params['region'])
                       .pluck(params[:search_type])
    response_json unmatched_values: (params[:search_data] - query_result)
  end

  def index
    unless ProfilePolicy.new(current_user, Profile).index?
      raise Pundit::NotAuthorizedError
    end
    profiles = search_query.page.page(params[:page]).per(10)

    if params[:select_columns]
      select_columns = params[:select_columns]
    else
      if params[:subordinate]
        select_columns = SelectColumnTemplate.default_select_columns
      else
        select_columns = SelectColumnTemplate.default_columns(region: params[:region])
      end
    end

    #unshift photo to fields
    select_columns.unshift('photo')
    fields = Field.find_in(select_columns)
    result = {
        fields: fields.as_json,
        profiles: profiles.map { |profile|
          {id: profile.id}.merge(profile.as_json_only_fields(select_columns))
        }
    }

    meta = {
        total_count: profiles.total_count,
        current_page: profiles.current_page,
        total_pages: profiles.total_pages
    }

    response_json result, meta: meta
  end

  def index_by_department
    authorize Profile
    profiles = search_query(:by_department).page.page(params[:page]).per(10)
    if params[:select_columns]
      select_columns = params[:select_columns]
    else
      if params[:subordinate]
        select_columns = SelectColumnTemplate.default_select_columns
      else
        select_columns = SelectColumnTemplate.default_columns(region: params[:region])
      end
    end

    #unshift photo to fields
    select_columns.unshift('photo')
    fields = Field.find_in(select_columns)
    result = {
        fields: fields.as_json,
        profiles: profiles.map { |profile|
          {id: profile.id}.merge(profile.as_json_only_fields(select_columns))
        }
    }

    meta = {
        total_count: profiles.total_count,
        current_page: profiles.current_page,
        total_pages: profiles.total_pages
    }

    response_json result, meta: meta
  end

  def export_xlsx
    unless ProfilePolicy.new(current_user, Profile).export_xlsx?
      raise Pundit::NotAuthorizedError
    end
    profiles = search_query

    fields_lang = params[:fields_lang] && 'en' == params[:fields_lang] ? 'english_name' : 'chinese_name'

    fields = Field.find_in(params[:select_columns])

    result = {
        fields: fields.as_json.map { |f| [f['key'], f[fields_lang]] }.to_h,
        records: profiles.map { |profile|
          profile.as_json_only_fields(params[:select_columns])
        },
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    profiles_export_number_tag = Rails.cache.fetch('profiles_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000"+ profiles_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('profiles_export_number_tag', profiles_export_number_tag + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t('profiles.xlsx_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateTableJob.perform_later(data: result, my_attachment: my_attachment)
    render json: my_attachment

  end

  def create
    unless ProfilePolicy.new(current_user, Profile).create?
      raise Pundit::NotAuthorizedError
    end
    region = params[:region]
    sections = params.require(:sections).as_json
    forked_template = Profile.fork_template(region: region, params: sections)
    ActiveRecord::Base.transaction do
      user = User.new
      user.password = TEST_PASSWORD if Object.const_defined?('TEST_PASSWORD')
      user.save!
      profile = user.build_profile
      profile.sections = forked_template
      profile.save!
      if params[:attachments]
        params[:attachments].each do |attach|
          profile.profile_attachments.create(creator_id: current_user.id).update(attach.permit(:file_name, :profile_attachment_type_id, :description, :attachment_id))
        end
      end
      if params[:contract_informations]
        params[:contract_informations].each do |attach|
          profile.contract_informations.create(creator_id: current_user.id).update(attach.permit(:file_name, :contract_information_type_id, :description, :attachment_id))
        end
      end
      if params[:work_experences]
        params[:work_experences].each do |attach|
          profile.work_experences.create(creator_id: current_user.id).update(attach.permit(:company_organazition, :work_experience_position, :work_experience_from, :work_experience_to,:job_description,
                                                                                        :work_experience_salary, :work_experience_reason_for_leaving, :work_experience_company_phone_number,:former_head,:work_experience_email))
        end
      end
      if params[:education_informations]
        params[:education_informations].each do |attach|
          profile.education_informations.create(creator_id: current_user.id).update(attach.permit(:highest, :from_mm_yyyy, :to_mm_yyyy, :college_university, :educational_department, :graduate_level,:graduated,:diploma_degree_attained,:certificate_issue_date))
        end
      end
      if params[:family_declaration_items]
        params[:family_declaration_items].each do |attach|
          profile.family_declaration_items.update(attach.permit(:relative_relation, :family_member_id).merge({ creator_id: current_user.id }))
        end
      end
      # 专业资格
      if params[:professional_qualifications]
        ProfessionalQualification.create_records(profile,params[:professional_qualifications])
      end

      if params[:special_schedule_remarks]
        SpecialScheduleRemark.create_records(profile, params[:special_schedule_remarks])
      end

      wr = WelfareRecord.create!(params[:welfare_record].permit(*welfare_required_array + welfare_permitted_array).merge(user_id: user.id, welfare_begin: profile.data['position_information']['field_values']['date_of_employment']))
      SalaryRecord.create!(params[:salary_record].permit(*salary_required_array + salary_permitted_array).merge(user_id: user.id, salary_begin: profile.data['position_information']['field_values']['date_of_employment']))
      Wrwt.create!(params[:wrwt].permit(*[:provide_airfare, :provide_accommodation, :airfare_type, :airfare_count]).merge(user_id: user.id))
      LoveFund.create_with_params(user, cal_cul_valid_date(Time.zone.parse(params.require(:love_fund)[:valid_date])), params[:love_fund][:to_status], current_user.id)
      MedicalInsuranceParticipator.create_with_params(
        params[:medical_insurance_participator].permit(:valid_date, :to_status), profile, operator_id: current_user.id
      )
      group_id = params[:sections][:position_information][:field_values][:group] rescue nil
      CareerRecord.create_initial_record(
        {user_id: user.id,
         trial_period_expiration_date: Time.zone.parse(profile.data['position_information']['field_values']['date_of_employment']) + ActiveModelSerializers::SerializableResource.new(wr).serializer_instance.probation.days,
         company_name: user.company_name, location_id: user.location_id, position_id: user.position_id,
         department_id: user.department_id, grade: user.grade, group_id: group_id,
         division_of_job: profile.data['position_information']['field_values']['division_of_job'],
         employment_status: profile.data['position_information']['field_values']['employment_status'],
         inputer_id: current_user.id,
         career_begin: profile.data['position_information']['field_values']['date_of_employment']
        }
      )
      ss=ShiftStatus.create_with_params(user.id, params[:shift_status]&.permit(:is_shift))
      pc=PunchCardState.create_with_params(user.id, params[:punch_card_state]&.permit(:is_need, :effective_date, :creator_id))
      if params[:roster_model_state]
        rm=RosterModelState.create_with_params(user.id, params[:roster_model_state]&.permit(:roster_model_id, :start_date, :start_week_no))
      end
      if params[:roster_instruction]
        user.create_roster_instruction!(params[:roster_instruction].permit(:comment))
      end
      if params[:language]
        user.create_language_skill!(params[:language].permit(LanguageSkill.create_params))
      end
      if params[:family_member_information]
        user.create_family_member_information!(params[:family_member_information].permit(FamilyMemberInformation.create_params))
      end
      if params[:profit_conflict_information]
        user.create_profit_conflict_information!(params[:profit_conflict_information].permit(ProfitConflictInformation.create_params))
      end
      if params[:background_declaration]
        user.create_background_declaration!(params[:background_declaration].permit(BackgroundDeclaration.create_params))
      end
      TimelineRecordService.update_valid_date(user)
      response_json id: profile.id, user_id: user.id, source_id: pc.source_id
    end
  end

  def show
    unless ProfilePolicy.new(current_user, Profile).show?
      raise Pundit::NotAuthorizedError
    end unless (entry_from_mine? || entry_from_department?)
    profile = Profile.find(params[:id])
    if current_user.can?(:roster_instruction, :Profile)
      result = profile.as_json(methods: [:sections_with_resignation_info, :shift_status, :punch_card_state, :roster_model_state, :roster_object_info, :roster_instruction],  except: :data).as_json
      result = result.merge({'sections' => result['sections_with_resignation_info']})
    else
      result = profile.as_json(methods: [:sections_with_resignation_info],  except: :data).as_json
      result = result.merge({'sections' => result['sections_with_resignation_info']})
    end

    unless entry_from_mine?
      if !current_user.can?(:personal_information, :Profile)
        result = result.merge({'sections' => [{}, result['sections'][1]]})
      end
      if !current_user.can?(:position_information, :Profile)
        result = result.merge({'sections' => [result['sections'][0],{}]})
      end
    end
    response_json result
  end

  def head_title
    render json: @profile.head_title
  end

  def update
    profile = Profile.find(params[:id])
    action = params[:edit_action_type]
    edit_params = params[:params]
                      .to_unsafe_h
                      .with_indifferent_access
    unless current_user.can?("update_#{params[:params][:section_key]}".to_sym, :Profile)
      raise Pundit::NotAuthorizedError
    end

    res = profile.send(action, formed_edit_params(edit_params, action, profile))
    profile.is_stashed = false unless params[:from_applicant_profile]
    profile.save
    response_json res
  end


  def template
    unless ProfilePolicy.new(current_user, Profile).template?
      raise Pundit::NotAuthorizedError
    end
    region = params[:region]
    template = Profile.create_template(region: region)
    response_json template
  end

  def emails_for_autocomplete
    data = []
    data = User.where("users.email ilike ?", "%#{params[:email]}%").limit(50).pluck(:email) if params[:email].to_s.length > 2
    response_json data
  end

  def autocomplete
    data = {users: [], can_cached_in_frontend: false}
    if params[:key]
      users = User.where("concat_ws('||', users.email, users.chinese_name, users.english_name, users.simple_chinese_name, users.empoid) ilike ?", "%#{params[:key]}%")
                  .limit(200).select('id', 'email', 'empoid', 'chinese_name', 'english_name', 'simple_chinese_name', 'department_id', 'position_id', "location_id")
      data = {
          users: users.map do |user|
            u = user.as_json(include: [:department, :position, :location])
            u["fields_join"] = u.values.drop(1).join('||')
            u['grade'] = ProfileService.grade(user)
            u['date_of_employment'] = ProfileService.date_of_employment(user)&.strftime("%Y/%m/%d")
            u['group'] = ProfileService.group(user)
            u['group_id'] = ProfileService.group(user)&.id
            u['probation'] = ActiveModelSerializers::SerializableResource.new(user.welfare_records.by_current_valid_record_for_welfare_info.first).serializer_instance.probation rescue nil
            u['mobile_number'] = user.profile.data['personal_information']['field_values']['mobile_number']
            division_of_job_key = ProfileService.division_of_job(user)
            employment_status_key = ProfileService.employment_status(user)
            company_name_key = ProfileService.company_name(user)
            u['division_of_job'] = Config.get(:selects)['division_of_job']['options'].select { |op| op['key'] == division_of_job_key }.first
            u['employment_status'] = Config.get(:selects)['employment_status']['options'].select { |op| op['key'] == employment_status_key }.first
            u['company_name'] = Config.get(:selects)['company_name']['options'].select { |op| op['key'] == company_name_key }.first
            u['profile'] = user.profile.as_json(except: :data)
            u['type_of_id'] = user.profile.data['personal_information']['field_values']['type_of_id']
            u['head'] = card_with_user(user)
            u
          end,
          can_cached_in_frontend: users.count < 200
      }
    end

    response_json data
  end

  def autocomplete_employees
    data = {users: [], can_cached_in_frontend: false}
    if params[:empoid] || params[:chinese_name] || params[:english_name] || params[:id_card_number]
      users = User.left_outer_joins(
          :department, :position, :location
      ).select(
        'id','chinese_name', 'english_name', 'simple_chinese_name', 'empoid', 'department_id', 'position_id','location_id',
        'departments.chinese_name as department_chinese_name',
        'positions.chinese_name as position_chinese_name', 'email'
      )
      not_found_values = []
      if params[:empoid]
        users = users.where(empoid: params[:empoid])
        found_values = users.pluck(:empoid)
        not_found_values = params[:empoid].select { |item| !found_values.include? item }
      end
      if params[:chinese_name]
        users = users.where(chinese_name: params[:chinese_name])
        found_values = users.pluck(:chinese_name)
        not_found_values = params[:chinese_name].select { |item| !found_values.include? item }
      end
      if params[:english_name]
        ids =[]
        not_found_values = []
        params[:english_name].each do |english_name|
          temp_id = users.where("users.english_name like ? ", "%#{english_name}%").pluck(:id)
          not_found_values.push(english_name) if temp_id.size == 0
          ids = ids.concat(temp_id)
        end
        users = users.where(id: ids)
      end
      if params[:id_card_number]
        users = users.where(id_card_number: params[:id_card_number])
        found_values = users.pluck(:id_card_number)
        not_found_values = params[:id_card_number].select { |item| !found_values.include? item }
      end
      data = {
          users: users.map { |user|
            u = user.as_json(include: [:department, :position, :location])
            u1 = u.select { |k, v|
              k if !(k == 'department_chinese_name' || k == 'position_chinese_name') }
            u["fields_join"] = u1.values.drop(1).join('||')

            division_of_job_key = user.profile.data['position_information']['field_values']['division_of_job'] rescue nil
            u['division_of_job'] = Config.get(:selects)['division_of_job']['options'].select { |op| op['key'] == division_of_job_key }.first
            u },
          can_cached_in_frontend: users.as_json.count < 200,
          not_found_values: not_found_values
      }
    end
    response_json data
  end

  def attachment_missing
    authorize Profile
    profiles = Profile.joins(:user).where('region = ?', params[:region])
    profiles = profiles.with_blank_attachments.order(id: :asc).page.page(params[:page]).per(10)

    # fields_lang = 'manila' == params[:region] ? 'english_name' : 'chinese_name'
    select_columns = ['chinese_name', 'english_name', 'position', 'department', 'photo']
    fields = Field.find_in(select_columns)

    result = {
        fields: fields.as_json.map { |f| [f['key'], f[select_language.to_s]] },
        profiles: profiles.map { |profile|
          profile.as_json_only_fields(select_columns).merge({id: profile.id, filled_attachment_types: profile.filled_attachment_types, attachment_missing_sms_sent: profile.attachment_missing_sms_sent})
        }
    }

    meta = {
        total_count: profiles.total_count,
        current_page: profiles.current_page,
        total_pages: profiles.total_pages,
        positions: Position.select(:id, :chinese_name, :english_name).where(id: result[:profiles].map { |profile| profile['position'] }),
        department: Department.select(:id, :chinese_name, :english_name).where(id: result[:profiles].map { |profile| profile['department'] })
    }

    response_json result, meta: meta
  end

  def attachment_missing_export
    authorize Profile
    profiles = Profile.joins(:user).where('region = ?', params[:region]).with_blank_attachments.order(id: :asc)

    #fields_lang = 'manila' == params[:region] ? 'english_name' : 'chinese_name'
    fields_lang = case I18n.locale.to_s
                  when 'zh-CN'
                    'simple_chinese_name'
                  when 'en'
                    'english_name'
                  else
                    'chinese_name'
                end
    select_columns = ['empoid', 'chinese_name', 'english_name', 'position', 'department']
    fields = Field.find_in(select_columns)

    all_attachment_types = ProfileAttachmentType.all
    type_header = all_attachment_types.map { |t| [t.id, t.try(fields_lang.to_sym)] }
    result = {
        fields: fields.as_json.map { |f| [f['key'], f[fields_lang]] }.to_h.merge(type_header.to_h),
        records: profiles.map { |profile|
          profile_item = profile.as_json_only_fields(select_columns)
          profile_item.merge(profile.attachment_result(all_attachment_types.pluck(:id), fields_lang))
              .merge({'position' => profile.user.position.try(fields_lang), 'department' => profile.user.department.try(fields_lang)})
        },
    }

    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    attachment_missing_number_tag = Rails.cache.fetch('attachment_missing_number_tag', :expires_in => 24.hours) do
      1
    end

    export_id = ( "0000"+attachment_missing_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('attachment_missing_number_tag', attachment_missing_number_tag + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "缺失入職文件#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateTableJob.perform_later(data: result.to_json, my_attachment: my_attachment)
    render json: my_attachment
  end

  def attachment_missing_sms_sent
    profile = Profile.find(params[:id])
    profile.update_attributes(attachment_missing_sms_sent: true)
    profile.save

    response_json
  end

  def query_applicant_profile_id_card_number
    id_card_number = params[:id_card_number]
    applicant_profile = ApplicantProfile.where(id_card_number: id_card_number).first
    if applicant_profile
      profile = User.where(id_card_number: id_card_number).first.try(:profile)
      if profile
        response_json action: :edit_profile, profile_id: profile.id
      else
        response_json action: :create_profile, applicant_profile_template_id: applicant_profile.id
      end
    else
      response_json action: :create_profile
    end
  end

  def holiday_info
    user = @user
    data = {}
    data['annual_leave'] =  HolidayRecord.calc_annual_leave_count_until_date(user, params[:now] || Time.zone.now.to_date)
    data['sick_leave'] =  HolidayRecord.calc_surplus(user, 'paid_sick_leave', Time.zone.now.year)
    data['paid_leave'] =  HolidayRecord.calc_surplus(user, 'paid_bonus_leave', Time.zone.now.year)
    response_json data
  end



  def my_avatar
    response_json current_user.profile.data['personal_information']['field_values']['photo']
  end

  private

  def set_profile
    @profile = Profile.find(params[:id])
  end

  def search_query(query_key = nil)
    if query_key == :by_department
      profile_ids = current_user.department.users.map{|user| user&.profile&.id}&.compact&.uniq&.sort
      profiles_query = Profile.where(id: profile_ids).joins(:user)
    else
      profiles_query = Profile.not_stashed.joins(:user).where('region = ?', params[:region])
    end

    # profiles_query = ProfilePolicy::Scope.new(current_user, profiles_query).resolve

    if params[:location_id]
      profiles_query = profiles_query.where('users.location_id in (?)', params[:location_id])
    end

    if params[:department_id]
      profiles_query = profiles_query.where('users.department_id in (?)', params[:department_id])
    end

    if params[:position_id]
      profiles_query = profiles_query.where('users.position_id in (?)', params[:position_id])
    end

    if params[:company_name]
      profiles_query = profiles_query.where('users.company_name in (?)', params[:company_name])
    end

    if params[:employment_status]
      profiles_query = profiles_query.where('users.employment_status in (?)', params[:employment_status])
    end

    if params[:grade]
      profiles_query = profiles_query.where('users.grade in (?)', params[:grade])
    end

    if params[:search_type]
      if params[:search_data].is_a?(Array)
        profiles_query = profiles_query.where("users.#{params[:search_type]}" => params[:search_data])
      else
        profiles_query = profiles_query.where("users.#{params[:search_type]} ilike ?", "%#{params[:search_data]}%")
      end
    end


    if params[:working_status] &&  params[:status_start_date] && params[:status_end_date]
      profiles_query = profiles_query.by_working_status(params[:working_status], params[:status_start_date], params[:status_end_date])
    end

    profiles_query.order("users.empoid")
  end




  def search_sick_leave(profile, to_date)
    sick_leave = profile.data['holiday_information']['field_values']['sick_leave'].to_i
    now_sick_leave = profile.get_remaining_sick_leave_days
    year, month, day = to_date.split('/')
    to_date = Time.zone.local(year, month, day)
    next_year = Time.zone.now.beginning_of_year + 1.year
    add_year =((to_date-next_year)/(Config.get(:constants_collection)['OneYear'])).ceil
    if add_year >= 1
      final_sick_leave = now_sick_leave + add_year * sick_leave
    else
      final_sick_leave = now_sick_leave
    end
    if sick_leave == 0
      sick_leave
    else
      final_sick_leave
    end
  end

  def card_with_user(user_record)
    empoids = []
    CardProfile.all.each{|record|
      unless record.empoid.nil?
        empoids.push record.empoid
      end
    }
    if empoids.include? user_record.empoid
      true
    else
      false
    end
  end

  def set_user
    @user = User.find(params[:id])
  end

  def get_user
    @user = Profile.find(params[:id]).user
  end


end
