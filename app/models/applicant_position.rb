# coding: utf-8
# == Schema Information
#
# Table name: applicant_positions
#
#  id                   :integer          not null, primary key
#  department_id        :integer
#  position_id          :integer
#  applicant_profile_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  order                :string
#  status               :integer          default("not_started")
#  comment              :text
#
# Indexes
#
#  index_applicant_positions_on_applicant_profile_id  (applicant_profile_id)
#  index_applicant_positions_on_department_id         (department_id)
#  index_applicant_positions_on_order                 (order)
#  index_applicant_positions_on_position_id           (position_id)
#

class ApplicantPosition < ApplicationRecord
  has_many :interviews
  has_many :contracts
  belongs_to :department
  belongs_to :position
  belongs_to :applicant_profile
  has_many :application_logs
  has_many :agreement_files
  has_many :audiences
  after_save :create_profile
  after_update :sent_entry_message_to_people
  after_create :send_new_applicant_position_message_to_people

  enum status: {
    not_started: 0,
    choose_needed: 1,
    choose_failed: 2,
    choose_succeed: 3,

    first_interview_agreed: 10,
    first_interview_rejected: 11,
    first_interview_absent: 12,
    first_interview_succeed: 13,

    second_interview_agreed: 20,
    second_interview_rejected: 21,
    second_interview_absent: 22,
    second_interview_succeed: 23,

    third_interview_agreed: 30,
    third_interview_rejected: 31,
    third_interview_absent: 32,
    third_interview_succeed: 33,

    discard: 40,

    accepted: 41,
    not_accepted: 42,

    offer_accepted: 43,
    offer_rejected: 44,

    contract_needed: 45,
    contract_not_finished: 46,

    entry_needed: 50,
    entry_finished: 51,
    entry_not_finished: 52
  }

  def self.chinese_statuses
    {
      not_started: '未啟動',
      choose_needed: '待初篩',
      choose_failed: '未通過初篩',
      choose_succeed: '通過初篩',
      first_interview_agreed: '同意第一次面試',
      first_interview_rejected: '拒絕第一次面試',
      first_interview_absent: '未出席第一次面試',
      first_interview_succeed: '通過第一次面試',
      second_interview_agreed: '同意第二次面試',
      second_interview_rejected: '拒絕第二次面試',
      second_interview_absent: '未出席第二次面試',
      second_interview_succeed: '通過第二次面試',
      third_interview_agreed: '同意第三次面試',
      third_interview_rejected: '拒絕第三次面試',
      third_interview_absent: '未出席第三次面試',
      third_interview_succeed: '通過第三次面試',
      discard: '暫不考慮',
      accepted: '錄取',
      not_accepted: '不獲錄取',
      offer_accepted: '接受offer',
      offer_rejected: '拒絕offer',
      contract_needed: '待簽約',
      contract_not_finished: '未簽約',
      entry_needed: '待入職',
      entry_finished: '已入職',
      entry_not_finished: '未入職'
    }
  end

  def self.english_statuses
    {
      not_started: "No start",
      choose_needed: "Wait for screening",
      choose_failed: "Not screened",
      choose_succeed: "Pass screened",
      first_interview_agreed: "Agree with the first interview",
      first_interview_rejected: "Reject the first interview",
      first_interview_absent: "Not attend the first interview",
      first_interview_succeed: "Pass the first interview",
      second_interview_agreed: "Agree with the second interview",
      second_interview_rejected: "Reject the second interview",
      second_interview_absent: "Not attend the second interview",
      second_interview_succeed: "Pass the second interview",
      third_interview_agreed: "Agree with the third interview",
      third_interview_rejected: "Reject the third interview",
      third_interview_absent: "Not attend the third interview",
      third_interview_succeed: "Pass the third interview",
      discard: "Put aside",
      accepted: "Admission",
      not_accepted: "No admission",
      offer_accepted: "Accept offer",
      offer_rejected: "Reject offer",
      contract_needed: "Wait for signing",
      contract_not_finished: "Unsigned",
      entry_needed: "Wait for entry",
      entry_finished: "Entry",
      entry_not_finished: "No entry"
    }
  end

  def self.simple_chinese_statuses
    {
        not_started: '未启动',
        choose_needed: '待初筛',
        choose_failed: '未通过初筛',
        choose_succeed: '通过初筛',
        first_interview_agreed: '同意第一次面试',
        first_interview_rejected: '拒绝第一次面试',
        first_interview_absent: '未出席第一次面试',
        first_interview_succeed: '通过第一次面试',
        second_interview_agreed: '同意第二次面试',
        second_interview_rejected: '拒绝第二次面试',
        second_interview_absent: '未出席第二次面试',
        second_interview_succeed: '通过第二次面试',
        third_interview_agreed: '同意第三次面试',
        third_interview_rejected: '拒绝第三次面试',
        third_interview_absent: '未出席第三次面试',
        third_interview_succeed: '通过第三次面试',
        discard: '暂不考虑',
        accepted: '录取',
        not_accepted: '不获录取',
        offer_accepted: '接受offer',
        offer_rejected: '拒绝offer',
        contract_needed: '待签约',
        contract_not_finished: '未签约',
        entry_needed: '待入职',
        entry_finished: '已入职',
        entry_not_finished: '未入职'
    }
  end

  def agreement_file_data
    {
      'chinese_name' => self.applicant_profile.chinese_name,
      'english_name' => self.applicant_profile.english_name,
      'id_card_number' => self.applicant_profile.id_card_number,
      'department_chinese_name' => self.department.try(:chinese_name),
      'department_english_name' => self.department.try(:english_name),
      'position_chinese_name' => self.position ? ApplicantPosition.remove_parentheses(self.position.chinese_name) : nil,
      'position_english_name' => self.position ? ApplicantPosition.remove_parentheses(self.position.english_name) : nil,
      "today_date" => Time.now.strftime("%Y 年 %m 月 %d 日"),
      "empoid" => self.applicant_profile.try(:empoid),
      "id_card_type" => self.applicant_profile.type_of_id_value.fetch("chinese_name", ""),
      "grade" => self.position.try(:grade),
      "mobile_number" => self.applicant_profile.get_personal_information.fetch("mobile_number", ""),
      "superior_chinese_name" => self.department.try(:head).try(:chinese_name),
      "salary_information" => OpenStruct.new(self.applicant_profile.get_salary_information)
    }
  end

  def ApplicantPosition.remove_parentheses(str)
    str.chomp(/\(.*\)/.match(str).to_s)
  end

  def logs_count
    application_logs.count
  end

  def interviews_count
    interviews.count
  end

  def status_object
    {
      key: self.status,
      chinese_name: self.class.chinese_statuses[self.status.to_sym],
      english_name: self.class.english_statuses[self.status.to_sym],
      simple_chinese_name: self.class.simple_chinese_statuses[self.status.to_sym]
    }
  end

  def contracts_count
    contracts.count
  end

  def is_pending_position?
    self.department_id.nil? && self.position_id.nil?
  end

  # wrong method name; interview_agreed_count
  def self.interview_failed_count
    where(status: [:first_interview_agreed, :second_interview_agreed, :third_interview_agreed]).count
  end

  def create_profile
    self.applicant_profile.update(empoid_for_create_profile: ProfileService.generate_empoid) if self.status.to_sym == :accepted && self.applicant_profile.empoid_for_create_profile.nil?
  end

  # private
  def sent_entry_message_to_people
    ap = self.applicant_profile
    if self.status == 'entry_finished'
      # send_users_ids = []
      # Role.find_each do |r|
      #   send_users_ids += r.user_ids unless r.permissions.where(:action => "receive_entry_finished", :region => ap.region).empty?
      # end
      # send_users_ids.uniq!

      # recruit_group_users = Role.find_by(key: 'recruit_group')&.users
      payment_group_users = Role.find_by(key: 'payment_group')&.users
      Message.add_notification(ap, "applicant_already_entry", payment_group_users.pluck(:id).uniq) unless (payment_group_users.nil? || payment_group_users.empty?)
      # Message.add_notification(ap, "applicant_already_entry", send_users_ids) unless send_users_ids.empty?
    end
  end

  def send_new_applicant_position_message_to_people
    ap = self
    profile = self.applicant_profile
    sent_message = !self.applicant_profile.try(:applicant_no).blank?
    if sent_message
      # send_users_ids = []
      # Role.find_each do |r|
      #   send_users_ids += r.user_ids unless r.permissions.where(:action => "receive_new_entry", :region => profile.region).empty?
      # end
      # send_users_ids.uniq!
      # Message.add_notification(ap, "applicant_position_created", send_users_ids) unless send_users_ids.empty?

      recruit_group_users = Role.find_by(key: 'recruit_group')&.users
      Message.add_notification(ap, "applicant_position_created", recruit_group_users.pluck(:id).uniq) unless (recruit_group_users.nil? || recruit_group_users.empty?)
    end
  end
end
