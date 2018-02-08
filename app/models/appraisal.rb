# coding: utf-8
# == Schema Information
#
# Table name: appraisals
#
#  id                             :integer          not null, primary key
#  appraisal_status               :string
#  appraisal_name                 :string
#  date_begin                     :datetime
#  date_end                       :datetime
#  participator_amount            :integer
#  ave_total_appraisal            :decimal(5, 2)
#  ave_superior_appraisal         :decimal(5, 2)
#  ave_colleague_appraisal        :decimal(5, 2)
#  ave_subordinate_appraisal      :decimal(5, 2)
#  ave_self_appraisal             :decimal(5, 2)
#  appraisal_introduction         :string
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  group_situation                :jsonb
#  complete_questionnaire         :boolean
#  participator_department_amount :integer
#  ave_department_appraisal       :decimal(5, 2)
#  total_ave_self_appraisal       :decimal(5, 2)
#  release_reports                :boolean
#  release_interviews             :boolean
#

class Appraisal < ApplicationRecord

  validates :appraisal_name, presence: true
  validates :date_begin, presence: true
  validates :date_end, presence: true

  has_many :appraisal_participators, dependent: :destroy
  has_many :appraisal_attachments, :as => :appraisal_attachable, dependent: :destroy
  has_many :appraisal_questionnaires, dependent: :destroy
  has_many :performance_interviews, dependent: :destroy
  has_many :appraisal_reports, dependent: :destroy
  has_many :appraisal_participate_departments, dependent: :destroy
  has_many :assess_relationships
  enum appraisal_status: {unpublished: 'unpublished',
                          to_be_assessed: 'to_be_assessed',
                          assessing: 'assessing',
                          completed: 'completed',
                          performance_interview: 'performance_interview'}

  def update_self_score
    reports = self.appraisal_reports
    # reports_for_mine = self.appraisal_participators.where(user_id: current_user.id).appraisal_report
    # reports_for_department = self.appraisal_participators.where(department_id: current_user.department_id) do |item|
    #   item.appraisal_report
    # end
    count = reports.count == 0 ? 1 : reports.count
    # count_department = reports_for_department.count == 0 ? 1 : reports_for_department.count
    self.update(
        ave_total_appraisal: reports.sum(:overall_score) / count,
        ave_superior_appraisal: reports.sum(:superior_score) / count,
        ave_colleague_appraisal: reports.sum(:colleague_score) / count,
        ave_subordinate_appraisal: reports.sum(:subordinate_score) / count,
        ave_self_appraisal: reports.sum(:self_score) / count,
        # total_ave_self_appraisal: reports_for_mine.sum(:overall_score),
        # ave_department_appraisal: reports_for_department.sum(:overall_score) / count_department

    )
  end


  def update_participator_count
    self.update(participator_amount: self.appraisal_participators.count)
  end

  def update_department_participator_amount
    participators = self.appraisal_participators
    self.appraisal_participate_departments.each do |appd|
      amount = participators.where(location_id: appd.location_id, department_id: appd.department_id).count
      appd.update(participator_amount: amount)
    end
  end

  # 删除评核下候选人关系
  def clear_candidate_relationships
    CandidateRelationship.where(appraisal_id: self.id).destroy_all
  end

  # 设置评核下候选人关系
  def set_candidate_relationships
    self.appraisal_participators.each do |participator|
      participator.create_candidate_participators
    end
  end

  def reset_candidate_relationships
    CandidateRelationship.where(appraisal_id: self.id).destroy_all
    self.appraisal_participators.each do |participator|
      participator.create_candidate_participators
    end
  end

  def appraisal_meet_the_assessment_conditions
    not_match_users = []
    self.appraisal_participators.each do |participator|
      relationships = participator.assess_relationships
      superiors = relationships.where(assess_type: 'superior_assess').count
      colleagues = relationships.where(assess_type: 'colleague_assess').count
      subordinates = relationships.where(assess_type: 'subordinate_assess').count
      if (superiors < 1) || (colleagues < 3) || (subordinates < 1)
        not_match_users << participator.user
      end
    end
    not_match_users
  end

  def check_settings
    # 检查员工设定是否完整 (员工设定完成的前提是部门设定完整)
    AppraisalEmployeeSetting.where(has_finished: false).size == 0
  end

  def change_status_to_assessing
    # 改变状态 -> 评核中
    self.update(appraisal_status: :assessing)
    # 固化 评核人员的评核分组、部门内分组及评核模板
    self.appraisal_participators.each {|participator| participator.regularize_settig}
  end

  def get_json_data
    data = self.as_json
    data[:appraisal_date] = "#{self.date_begin.strftime('%Y/%m/%d')} ~ #{self.date_end.strftime('%Y/%m/%d')}"
    data
  end

  after_update :add_notification

  def add_notification
    department_group_users = Role.find_by(key: 'department_group')&.users
    should_send_department_ids = User.where(id: AppraisalParticipator.where(appraisal_id: self.id)&.pluck(:user_id))&.pluck(:department_id)&.compact&.uniq
    sd_users = department_group_users&.where(department_id: should_send_department_ids)&.pluck(:id)

    case self.appraisal_status
    when 'to_be_assessed' then
      Message.add_notification(self,
                               'publishing_an_appraisal_notification',
                               sd_users,
                               {appraisal_date: "#{self.date_begin.strftime('%Y/%m/%d')} ~ #{self.date_end.strftime('%Y/%m/%d')}"}) unless sd_users&.empty?
    when 'performance_interview' then
      Message.add_notification(self,
                               'starting_performace_interview_notification',
                               sd_users,
                               {appraisal_date: "#{self.date_begin.strftime('%Y/%m/%d')} ~ #{self.date_end.strftime('%Y/%m/%d')}"}) unless sd_users&.empty?
      # when 'assessing' then
      #   Message.add_notification(self,
      #                            'starting_an_appraisal_notification',
      #                            sd_users,
      #                            {appraisal_date: "#{self.date_begin.strftime('%Y/%m/%d')} ~ #{self.date_end.strftime('%Y/%m/%d')}"}) unless sd_users.empty?
    end
  end

  def create_appraisal_attachments
    appraisal_attachments = AppraisalBasicSetting.first.appraisal_attachments
    ActiveRecord::Base.transaction do
      appraisal_attachments.each do |attachment|
        self.appraisal_attachments.create(attachment.attributes.slice(
            'file_name', 'file_type', 'creator_id', 'attachment_id', 'comment'
        ))
      end
      self.save!
    end
  end

  scope :by_appraisal_status, ->(appraisal_status) {
    where(appraisal_status: appraisal_status)
  }

  scope :by_appraisal_date, ->(appraisal_date) {
    from = Time.zone.parse(appraisal_date['begin']).beginning_of_day rescue nil
    to = Time.zone.parse(appraisal_date['end']).end_of_day rescue nil
    if from && to
      where('date_end >= :from AND date_begin <= :to', from: from, to: to)
    elsif from
      where('date_end >= :from', from: from)
    elsif to
      where('date_begin <= :to', to: to)
    end
  }

  scope :by_participator_amount, ->(participator_amount) {
    where(participator_amount: participator_amount)
  }

  scope :by_participator_department_amount, ->(participator_department_amount) {
    where(participator_department_amount: participator_department_amount)
  }

  scope :by_ave_total_appraisal, ->(ave_total_appraisal) {
    where(ave_total_appraisal: ave_total_appraisal)
  }

  scope :by_ave_superior_appraisal, ->(ave_superior_appraisal) {
    where(ave_superior_appraisal: ave_superior_appraisal)
  }

  scope :by_ave_colleague_appraisal, ->(ave_colleague_appraisal) {
    where(ave_colleague_appraisal: ave_colleague_appraisal)
  }

  scope :by_ave_subordinate_appraisal, ->(ave_subordinate_appraisal) {
    where(ave_subordinate_appraisal: ave_subordinate_appraisal)
  }

  scope :by_ave_self_appraisal, ->(ave_self_appraisal) {
    where(ave_self_appraisal: ave_self_appraisal)
  }
  scope :by_total_ave_self_appraisal, ->(total_ave_self_appraisal) {
    where(total_ave_self_appraisal: total_ave_self_appraisal)
  }
  scope :by_ave_department_appraisal, ->(ave_department_appraisal) {
    where(ave_department_appraisal: ave_department_appraisal)
  }


  scope :order_by, ->(sort_column, sort_direction){
    if sort_column.to_sym == :appraisal_date
      order(:date_begin  => sort_direction)
    else
      order(sort_column => sort_direction)
    end
  }

end
