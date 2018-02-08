# == Schema Information
#
# Table name: applicant_profiles
#
#  id                        :integer          not null, primary key
#  applicant_no              :string
#  chinese_name              :string
#  english_name              :string
#  id_card_number            :string
#  region                    :string
#  data                      :jsonb
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  source                    :string
#  profile_id                :integer
#  get_info_from             :jsonb
#  empoid_for_create_profile :string
#
# Indexes
#
#  index_applicant_profiles_on_applicant_no    (applicant_no)
#  index_applicant_profiles_on_chinese_name    (chinese_name)
#  index_applicant_profiles_on_english_name    (english_name)
#  index_applicant_profiles_on_id_card_number  (id_card_number)
#  index_applicant_profiles_on_profile_id      (profile_id)
#  index_applicant_profiles_on_region          (region)
#  index_applicant_profiles_on_source          (source)
#

class ApplicantProfile < ApplicationRecord
  MANUAL_SOURCE = 'manual'
  WEBSITE_SOURCE = 'website'
  IPAD_SOURCE = 'ipad'

  include ProfileAble
  include ApplicantProfileToProfileSectionsMapping

  has_many :applicant_positions
  has_many :applicant_attachments

  before_save :on_save
  after_initialize :fill_sections, :default_value
  before_create :on_create
  before_save :validate_get_info_from
  belongs_to :profile
  delegate :user, :to => :profile, :allow_nil => true

  validates :applicant_no, uniqueness: true


  def create_profile_info
    apply_position = self.applicant_positions.where(status: :entry_finished).order(created_at: :desc).first
    date_of_employment = self.data['position_to_apply']['field_values']['available_on']
    {
      position_id: apply_position&.position_id,
      department_id: apply_position&.department_id,
      date_of_employment: date_of_employment,
      seniority_calculation_date: date_of_employment,
      empoid: self.empoid
    }
  end

  def empoid

    self.profile_id ? self.profile.user.empoid : self.empoid_for_create_profile
  end

  def edit_applicant_no(applicant_no_params)
    self.applicant_no = applicant_no_params[:applicant_no]
  end

  def create_profile(applicant_position)
    if self.profile.blank?
      ActiveRecord::Base.transaction do
        user = User.new
        user.password = TEST_PASSWORD if Object.const_defined?('TEST_PASSWORD')
        user.save!

        the_profile = user.build_profile
        sections = forked_profile_template(applicant_position)
        the_profile.sections = Profile.fork_template(region: self.region, params: sections)
        the_profile.is_stashed = true
        the_profile.save!

        self.profile = the_profile
        self.save

        self.applicant_attachments.each do |attach|
          attachment_types_map_id = self.class.attachment_types_map(attach.applicant_attachment_type_id)
          if attachment_types_map_id
            the_profile.profile_attachments.create({
              file_name: attach.file_name,
              profile_attachment_type_id: attachment_types_map_id,
              description: attach.description,
              attachment_id: attach.attachment_id
            })
          end
        end
        profile
      end
    end
    self.profile
  end

  def forked_profile_template(applicant_position)
    ApplicantProfileToProfileSectionsMap.new(self, applicant_position).commit_mapping
  end

  def self.attachment_types_map(applicant_attachment_type_id)
    applicant_attachment_types = ApplicantAttachmentType.all.reduce({}) do |map, t|
      map[[t.chinese_name, t.english_name]] = t.id
      map
    end
    profile_attachment_types_map = ProfileAttachmentType.all.reduce({}) do |map, t|
      map[applicant_attachment_types[[t.chinese_name, t.english_name]]] = t.id if applicant_attachment_types[[t.chinese_name, t.english_name]]
      map
    end
    profile_attachment_types_map[applicant_attachment_type_id]
  end

  class << self
    def section_config_class
      ApplicantProfileSection
    end

    def pseudo_fields
      {
        'apply_department': {
          key: 'apply_department',
          chinese_name: '應徵部門',
          english_name: 'Branch',
          simple_chinese_name: '应征部门',
          type: 'object',
        },
        'apply_position': {
          key: 'apply_position',
          chinese_name: '應徵職位',
          english_name: 'Position',
          simple_chinese_name: '应征职位',
          type: 'object',
        },
        'apply_source': {
          key: 'apply_source',
          chinese_name: '申請途徑',
          english_name: 'Route',
          simple_chinese_name: '申请途径',
          type: 'object',
        },
        'apply_date': {
          key: 'apply_date',
          chinese_name: '申請日期',
          english_name: 'Apply Date',
          simple_chinese_name: '申请日期',
          type: 'string',
        },
        'apply_status': {
          key: 'apply_status',
          chinese_name: '求職進度',
          english_name: 'Apply Status',
          simple_chinese_name: '求职进度',
          type: 'object',
        },
      }.with_indifferent_access
    end

    def get_applicant_no
      def rjust(id)
        id.rjust(4, '0')
      end

      today_time_prefix = Time.zone.now.strftime("%y%m%d")
      last_profile = ApplicantProfile.where('applicant_no like ?', "R-#{today_time_prefix}%").last
      last_applicant_no = nil
      if last_profile
        last_applicant_no = last_profile.applicant_no
      end

      applicant_no = rjust('1')
      if last_applicant_no
        applicant_no = rjust((last_applicant_no.last(4).to_i + 1).to_s)
      end

      "R-#{today_time_prefix}#{applicant_no}"
    end
  end

  def on_create
    self.applicant_no = self.class.get_applicant_no
  end

  def pseudo_value(field)
    self.send("pseudo_#{field}")
  end

  def pseudo_apply_date
    self.created_at.strftime("%Y/%m/%d")
  end

  def pseudo_apply_source
    self.source_object
  end

  def pseudo_apply_status
    ApplicantPosition.find(self.applicant_position_id).status_object
  end

  def pseudo_apply_department
    apply_department = ApplicantPosition.find(self.applicant_position_id).department
    unless apply_department
      {
        chinese_name: '待定',
        english_name: 'Pending',
        simple_chinese_name: '待定'
      }
    else
      apply_department
    end
  end

  def pseudo_apply_position
    apply_position = ApplicantPosition.find(self.applicant_position_id).position
    unless apply_position
      {
        chinese_name: '待定',
        english_name: 'Pending',
        simple_chinese_name: '待定'
      }
    else
      apply_position
    end
  end

  def default_value
    self.source ||= self.class::MANUAL_SOURCE
  end

  def publish(event_name, params)
    change_choice = change_choice_partten(event_name)
    if change_choice
      choice_order = change_choice[:order]
      replace_applicant_position(choice_order, params)
    end

    sync_column = sync_column_partten(event_name)
    if sync_column
      attribute_name = sync_column[:attribute]
      if self.new_record?
        self.send("#{attribute_name}=", params)
      else
        self.update_column(attribute_name, *params)
      end
    end
  end

  def replace_applicant_position(order, job_id)

    #获取档案之前该顺序的申请职位
    origin_position = applicant_positions.where(order: order).first
    #设置的申请职位是待定
    if job_id == 'pending'
      need_replace_pending = false
      if !origin_position
        need_replace_pending = true
      end

      #有原始职位为非pending职位 删除原始职位
      if origin_position and !origin_position.is_pending_position?
        origin_position.delete
        need_replace_pending = true
      end

      #需要替换为pending状态
      if need_replace_pending
        applicant_positions << applicant_positions.build(
          department_id: nil,
          position_id: nil,
          order: order
        )
      end

      return
    end


    #查询替换后的职位对象
    begin
      job = Job::find(job_id)
    rescue ActiveRecord::RecordNotFound
      return
    end

    #如果存在原始职位并且和新的申请职位不一致，删除原有职位
    if origin_position
      if (origin_position.department_id != job.department_id) or (origin_position.position_id != job.position_id)
        origin_position.delete
      else
        return
      end
    end


    #构建新职位 存入
    applicant_position = applicant_positions.build(
      department_id: job.department_id,
      position_id: job.position_id,
      order: order
    )

    applicant_positions << applicant_position
  end

  def change_choice_partten(event_name)
    /^change_(?<order>\w+)_choice/.match(event_name)
  end

  def sync_column_partten(event_name)
    /^sync_with_user_(?<attribute>\w+)/.match(event_name)
  end

  def first_applicant_position_id
    begin
      applicant_positions.where(order: 'first').first.id
    rescue
      nil
    end
  end

  def first_applicant_position_status
    begin
      applicant_positions.where(order: 'first').first.status
    rescue
      nil
    end
  end

  def second_applicant_position_id
    begin
      applicant_positions.where(order: 'second').first.id
    rescue
      nil
    end
  end

  def second_applicant_position_status
    begin
      applicant_positions.where(order: 'second').first.status
    rescue
      nil
    end
  end

  def third_applicant_position_id
    begin
      applicant_positions.where(order: 'thrid').first.id
    rescue
      nil
    end
  end

  def third_applicant_position_status
    begin
      applicant_positions.where(order: 'thrid').first.status
    rescue
      nil
    end
  end

  def gender_chinese_name
    genders = { male: '男', female: '女'}
    gender = self.data.fetch("personal_information", {}).fetch("field_values", {}).fetch("gender", '')
    genders.fetch(gender.to_sym, '')
  end

  def type_of_id_value
    the_type_of_id = self.data.fetch("personal_information", {}).fetch("field_values", {}).fetch("type_of_id", "")
    type_of_id_value = Select.get_option(:type_of_id, the_type_of_id)
  end

  def get_personal_information
    self.data.fetch("personal_information", {}).fetch("field_values", {})
  end

  def get_salary_information
    self.data.fetch("salary_information", {}).fetch("field_values", {})
  end

  def source_object
    case self.source
      when 'ipad'
        {
          chinese_name: 'iPad',
          english_name: 'iPad',
          simple_chinese_name: 'iPad'
        }
      when 'manual'
        {
          chinese_name: '手動創建',
          english_name: 'Manual',
          simple_chinese_name: '手动创建'
        }
      when 'website'
        {
          chinese_name: '網站',
          english_name: 'WebSite',
          simple_chinese_name: '网站'
        }
    end
  end

  def validate_get_info_from
    if self.get_info_from
      get_info_from_selected = Array(self.get_info_from.fetch('selected', []))
      v = get_info_from_selected - Select.get_options(:get_info_from).map{|o| [:key]}
      self.get_info_from['internet_detail'] = '' unless get_info_from_selected.include?('internet')
      self.get_info_from['others_detail'] = '' unless get_info_from_selected.include?('others')
      v.blank?
    end
  end

  def edit_get_info_from(get_info_from)
    self.get_info_from = get_info_from
  end

end
