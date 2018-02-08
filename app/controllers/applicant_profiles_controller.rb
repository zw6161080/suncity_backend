  class ApplicantProfilesController < ApplicationController
  include ProfileHelper
  include GenerateXlsxHelper

  def advance_search_params_check
    query_result = ApplicantProfile
                        .where({params['search_type'] => params[:search_data]})
                        .where("applicant_profiles.region = ?", params['region'])
                        .pluck(params[:search_type])

    response_json unmatched_values: (params[:search_data] - query_result)
  end

  def index
    # authorize ApplicantProfile
    profiles = search_query.page(params[:page]).per(10)
    profiles_with_fields = profile_to_json_with_select_columns(
      profiles,
      [
        'photo', 'apply_department',
        'apply_position', 'apply_source',
        'apply_date', 'apply_status'
      ].concat(select_columns),
      ApplicantProfile
    )

    response_json profiles_with_fields, meta: {
        total_count: profiles.total_count,
        current_page: profiles.current_page,
        total_pages: profiles.total_pages
    }
  end

  def same_id_card_number_profiles
    profile = ApplicantProfile.find(params[:id])

    profiles = ApplicantProfile
                .where(region: params[:region])
                .where(id_card_number: profile.id_card_number).order("created_at desc")
    response_json profiles.as_json(only: [:id, :created_at])
  end

  def template
    region = params[:region]
    template = ApplicantProfile.template(region: region)
    response_json template
  end

  def create
    # authorize ApplicantProfile
    region = params[:region]
    sections = params.require(:sections).as_json

    if params[:source]
      source = params[:source]
    else
      source = 'manual'
    end

    attributes = {source: source}
    if params[:get_info_from]
      attributes[:get_info_from] = params[:get_info_from].as_json
    end
    applicant_profile = ApplicantProfile.fork_template!(region: region, params: sections, attributes: attributes)

    if params[:attachments]
      params[:attachments].each do |attach|
        applicant_profile.applicant_attachments.create(attach.permit(:file_name, :applicant_attachment_type_id, :description, :attachment_id))
      end
    end

    applicant_profile.applicant_positions.uniq.each do |ap|
      if ap
        log_user = ['ipad', 'website'].include? params[:source] ? nil : current_user
        LogService.new(:applicant_profile_created, log_user, applicant_profile).save_log(ap)
      end
    end
    applicant_profile.applicant_positions.first.choose_needed! if applicant_profile.applicant_positions.first

    response_json id: applicant_profile.id
  end

  def show
    # authorize ApplicantProfile
    applicant_profile = ApplicantProfile.find(params[:id])
    response_json applicant_profile.as_json(
      methods: [
        :empoid,
        :sections,
        :first_applicant_position_id,
        :first_applicant_position_status,
        :second_applicant_position_id,
        :second_applicant_position_status,
        :third_applicant_position_id,
        :third_applicant_position_status,
        :create_profile_info
      ],
      except: :data
    )
  end

  def update
    # authorize ApplicantProfile
    profile = ApplicantProfile.find(params[:id])
    action = params[:edit_action_type]

    edit_params = params[:params]
                  .to_unsafe_h
                  .with_indifferent_access
    if edit_params["section_key"] == "educational" && %w(edit_row_fields add_row).include?(action) && ((edit_params['new_row'].send(:[], :highest) == 'true') || (edit_params["fields"].send(:[], :highest) == 'true'))
      profile.data['educational']['rows'].each{|hash|
        profile.send("edit_row_fields", {
          section_key: "educational",
          row_id: hash['id'],
          fields: {
            highest: 'false'
          }
        }.with_indifferent_access)
      }
      profile.save! unless profile.data['educational']['rows'].empty?
    end
    res = profile.send(action, edit_params)
    profile.save!

    profile.applicant_positions.uniq.each do |ap|
      if params[:source] == 'ipad'
        log_user = nil
      else
        log_user = current_user
      end
      LogService.new(:applicant_profile_updated, log_user, profile).save_log(ap)
    end
    # Message.add_notification(profile, :applicant_profile_updated)

    response_json res
  end

  def export_xlsx
    fields_lang = params[:fields_lang] && 'en' == params[:fields_lang] ? 'english_name' : 'chinese_name'
    profiles_with_fields = profile_to_json_with_select_columns(
      search_query,
      ['apply_department', 'apply_position'].concat(select_columns),
      ApplicantProfile
    )
    profiles_with_fields[:fields] = profiles_with_fields[:fields].map{|field|
      [field['key'], field[fields_lang]]
    }.to_h
    applicant_profiles_export_number_tag = Rails.cache.fetch('applicant_profiles_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000"+ applicant_profiles_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('applicant_profiles_export_number_tag', applicant_profiles_export_number_tag + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "求職者檔案#{I18n.t('applicant_profiles.xlsx_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateTableJob.perform_later(data: profiles_with_fields, my_attachment: my_attachment)
    render json: my_attachment
  end

  def export_xlsx_with_apply_source_apply_date_apply_status
    fields_lang = select_language.to_s
    profiles_with_fields = profile_to_json_with_select_columns(
        search_query,
        ['apply_department', 'apply_position', 'apply_source',
         'apply_date', 'apply_status'].concat(select_columns),
        ApplicantProfile
    )
    profiles_with_fields[:fields] = profiles_with_fields[:fields].map{|field|
      [field['key'], field[fields_lang]]
    }.to_h
    export_xlsx_with_apply_source_apply_date_apply_status_export_num = Rails.cache.fetch('export_xlsx_with_apply_source_apply_date_apply_status_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+export_xlsx_with_apply_source_apply_date_apply_status_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('export_xlsx_with_apply_source_apply_date_apply_status_export_number_tag', export_xlsx_with_apply_source_apply_date_apply_status_export_num + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "求職者檔案#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateTableJob.perform_later(data: profiles_with_fields.to_json, my_attachment: my_attachment)
    render json: my_attachment
  end

  private
  def search_query
    applicant_profiles_query = ApplicantProfile.joins(:applicant_positions)
      .select('applicant_profiles.*, applicant_positions.id as applicant_position_id')

    if params[:advance_search]
      if params[:chinese_name]
        applicant_profiles_query = applicant_profiles_query.where(chinese_name: params[:chinese_name])
      end

      if params[:english_name]
        applicant_profiles_query = applicant_profiles_query.where(english_name: params[:english_name])
      end

      if params[:id_card_number]
        applicant_profiles_query = applicant_profiles_query.where(id_card_number: params[:id_card_number])
      end

      return applicant_profiles_query
    end

    if params[:applicant_no]
      applicant_profiles_query = applicant_profiles_query.where(applicant_no: params[:applicant_no])
    end

    if params[:chinese_name]
      applicant_profiles_query = applicant_profiles_query.where("english_name ilike ?": params[:chinese_name])
    end

    if params[:english_name]
      applicant_profiles_query = applicant_profiles_query.where("english_name ilike ?": params[:english_name])
    end

    if params[:search_type]
      if params[:search_data].is_a?(Array)
        applicant_profiles_query = applicant_profiles_query.where("#{params[:search_type]}" => params[:search_data])
      else
        applicant_profiles_query = applicant_profiles_query.where("#{params[:search_type]} ilike ?", "%#{params[:search_data]}%")
      end
    end

    if params[:id_card_number]
      applicant_profiles_query = applicant_profiles_query.where(id_card_number: params[:id_card_number])
    end

    if params[:source]
      applicant_profiles_query = applicant_profiles_query.where(source: params[:source])
    end

    if params[:created_at]
      begin
        query_date = params[:created_at].in_time_zone
        applicant_profiles_query = applicant_profiles_query.where(created_at: query_date.beginning_of_day..query_date.end_of_day)
      rescue

      end
    end

    if params[:department_id] && params[:department_id] != "pending"
        applicant_profiles_query = applicant_profiles_query.where(applicant_positions: {
            department_id: params[:department_id]
        })
    end
    if params[:department_id] == "pending"
      applicant_profiles_query = applicant_profiles_query.where(applicant_positions: {
          department_id: nil
      })
    end

    if params[:position_id] && params[:position_id] != "pending"
        applicant_profiles_query = applicant_profiles_query.where(applicant_positions: {
            position_id: params[:position_id]
        })
    end
    if params[:position_id] == "pending"
      applicant_profiles_query = applicant_profiles_query.where(applicant_positions: {
          position_id: nil
      })
    end

    if params[:applicant_position_status]
      query_status = params[:applicant_position_status]
      if query_status == 'waiting_for_interview'
        query_status = %W{first_interview_agreed second_interview_agreed third_interview_agreed}
      end

      applicant_profiles_query = applicant_profiles_query.where(applicant_positions: {
        status: query_status
      })
    end

    applicant_profiles_query.order('created_at desc, applicant_positions.id asc')
  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '求職者檔案'
    elsif select_language == 'english_name'
      '求职者档案'
    else
      'Applicant files'
    end
  end
end
