# coding: utf-8
# == Schema Information
#
# Table name: client_comments
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  client_account            :string
#  client_name               :string
#  client_fill_in_date       :datetime
#  client_phone              :string
#  client_account_date       :datetime
#  involving_staff           :string
#  event_time_start          :datetime
#  event_time_end            :datetime
#  event_place               :string
#  last_tracker_id           :integer
#  last_track_date           :datetime
#  last_track_content        :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  questionnaire_template_id :integer
#  questionnaire_id          :integer
#
# Indexes
#
#  index_client_comments_on_last_tracker_id  (last_tracker_id)
#  index_client_comments_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_9461948c2e  (user_id => users.id)
#  fk_rails_d7acf70406  (last_tracker_id => users.id)
#

class ClientComment < ApplicationRecord
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :last_tracker, :class_name => 'User', :foreign_key => 'last_tracker_id'
  has_many :client_comment_tracks, dependent: :destroy
  has_one :questionnaire_template
  has_one :questionnaire

  validates :user_id, :client_account, :client_name, :client_fill_in_date, :client_phone, :client_account_date, presence: true

  def self.options
    user_query = self.left_outer_joins(user: [:position, :department])
    departments = user_query.select('departments.*').distinct.as_json
    positions = user_query.select('positions.*').distinct.as_json
    questionnaire_templates = QuestionnaireTemplate.where(template_type: 'client_feedback').as_json
    {
      department: departments,
      position: positions,
      questionnaire_template: questionnaire_templates,
    }
  end

  after_create :send_notification
  def send_notification
    # TODO 培訓組HR
    training_group_users = Role.find_by(key: 'training_group')&.users
    Message.add_notification(self,
                             'submitted_a_client_comment',
                             training_group_users.pluck(:id).uniq,
                             { employee: User.find(self.user_id) }) unless (training_group_users.nil? || training_group_users.empty?)
  end

  def get_json_data
    rst = self.as_json(include: [
                         { user: { include: [:department, :position]}},
                         :last_tracker
                       ])
    if self.questionnaire_template_id
      rst['questionnaire_template'] = QuestionnaireTemplate.find(self.questionnaire_template_id).as_json
    end
    rst
  end

  scope :by_user_id, ->(user_id) {
    # 用于区分：客户意见 我的客户意见
    where(user_id: user_id)
  }

  scope :by_employee_name, ->(name) {
    where(user_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_employee_id, ->(empoid) {
    where(user_id: User.where(empoid: empoid).select(:id))
  }

  scope :by_department, ->(department_id) {
    where(user_id: User.where(department_id: department_id).select(:id))
  }

  scope :by_position, ->(position_id) {
    where(user_id: User.where(position_id: position_id).select(:id))
  }

  scope :by_client_fill_in_date, ->(client_fill_in_date) {
    from = (Time.zone.parse(client_fill_in_date[:begin])).beginning_of_day rescue nil
    to   = (Time.zone.parse(client_fill_in_date[:end])).end_of_day rescue nil
    if from && to
      where('client_fill_in_date >= :from AND client_fill_in_date <= :to', from: from, to: to)
    elsif from
      where('client_fill_in_date >= :from', from: from)
    elsif to
      where('client_fill_in_date <= :to', to: to)
    end
  }

  scope :by_client_account, ->(client_account) {
    where(client_account: client_account)
  }

  scope :by_client_name, ->(client_name) {
    where(client_name: client_name)
  }

  scope :by_questionnaire_template, ->(questionnaire_template) {
    where(questionnaire_template_id: questionnaire_template)
  }

  scope :by_last_tracker, ->(name) {
    where(last_tracker_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_last_track_date, ->(last_track_date) {
    from = (Time.zone.parse(last_track_date[:begin])).beginning_of_day rescue nil
    to   = (Time.zone.parse(last_track_date[:end])).end_of_day rescue nil
    if from && to
      where('last_track_date >= :from AND last_track_date <= :to', from: from, to: to)
    elsif from
      where('last_track_date >= :from', from: from)
    elsif to
      where('last_track_date <= :to', to: to)
    end
  }

end
