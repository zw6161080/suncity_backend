# == Schema Information
#
# Table name: punishments
#
#  id                            :integer          not null, primary key
#  punishment_category           :string
#  punishment_content            :string
#  punishment_result             :string
#  punishment_remarks            :string
#  user_id                       :integer
#  incident_customer_involved    :boolean
#  incident_employee_involved    :boolean
#  incident_casino_involved      :boolean
#  incident_thirdparty_involved  :boolean
#  incident_suspended            :boolean
#  target_response_title         :boolean
#  target_response_content       :string
#  target_response_datetime_from :datetime
#  target_response_datetime_to   :datetime
#  reinstated                    :boolean
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  punishment_date               :datetime
#  incident_suspended_date       :datetime
#  reinstated_date               :datetime
#  incident_money_involved       :decimal(10, 2)
#  track_date                    :datetime
#  tracker_id                    :integer
#  punishment_status             :string
#  incident_time_from            :datetime
#  incident_time_to              :datetime
#  incident_place                :string
#  incident_discoverer           :string
#  incident_discoverer_phone     :string
#  incident_handler              :string
#  incident_handler_phone        :string
#  incident_description          :string
#  incident_financial_influence  :boolean
#  records_in_where              :string
#  profile_validity_period       :integer
#  profile_penalty_score         :integer
#  profile_abolition_date        :datetime
#  profile_punishment_status     :string
#  profile_remarks               :string
#  salary_deduct_status          :boolean          default(FALSE)
#  is_poor_attendance            :boolean
#
# Indexes
#
#  index_punishments_on_punishment_category  (punishment_category)
#  index_punishments_on_punishment_result    (punishment_result)
#  index_punishments_on_tracker_id           (tracker_id)
#  index_punishments_on_user_id              (user_id)
#
# Foreign Keys
#
#  fk_rails_4f327faa0f  (tracker_id => users.id)
#  fk_rails_f69258556d  (user_id => users.id)
#

class Punishment < ApplicationRecord
  include JobTransferAble
  belongs_to :user, :class_name => 'User', :foreign_key => 'user_id'
  belongs_to :tracker, :class_name => 'User', :foreign_key => 'tracker_id'
  has_many :approval_items, as: :approvable, dependent: :destroy
  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_one :profile

  enum punishment_status:   { punishing: 'punishment.enum_punishment_status.punishing',
                              punished:  'punishment.enum_punishment_status.punished' }

  enum punishment_result:   { cancel_warning_letter:  'punishment.enum_punishment_result.cancel_warning_letter',
                              verbal_warning:         'punishment.enum_punishment_result.verbal_warning',
                              classA_written_warning: 'punishment.enum_punishment_result.classA_written_warning',
                              classB_written_warning: 'punishment.enum_punishment_result.classB_written_warning',
                              final_written_warning:  'punishment.enum_punishment_result.final_written_warning',
                              fired:                  'punishment.enum_punishment_result.fired' }


  enum records_in_where:   { profile: 'profile',
                             not_profile: 'not_profile' }

  enum profile_punishment_status: { in_effect: 'punishment.profile_punishment_status.in_effect',
                                    cancelled: 'punishment.profile_punishment_status.cancelled',
                                    logout:    'punishment.profile_punishment_status.logout' }

  def self.field_options
    user_query = self.left_outer_joins(user: [:position, :department])
    positions = user_query.select('positions.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    return {
        positions: positions,
        departments: departments,
        punishment_statuses:   Config.get('punishments').fetch('punishment_statuses', []),
        punishment_results:    Config.get('punishments').fetch('punishment_results', []),
        punishment_categories: Config.get('punishments').fetch('punishment_categories', []),
    }
  end

  def self.detail_by_id(id)
    Punishment
        .includes({user:             [:location, :department, :position]},
                  {approval_items:   {user: [:department, :position]}},
                  {attend_attachments: [:creator]})
        .find(id)
  end

  def self.detail_by_user_id(id)
    Punishment
        .includes(:user)
        .where(user_id: id )
        .where(records_in_where: 'profile', )
  end

  def self.auto_logout_profile_punishment
    Punishment
        .where(records_in_where: 'profile')
        .where(profile_punishment_status: 'in_effect')
        .where('profile_abolition_date <= :date', date: Time.zone.now).each do |punishment|
      unless Punishment
                 .where(user_id: punishment.user_id)
                 .where(records_in_where: 'profile')
                 .where(profile_punishment_status: 'in_effect')
                 .where('profile_abolition_date > :date', date: Time.zone.now)
                 .empty?
        punishment.update(profile_punishment_status: 'punishment.profile_punishment_status.logout')
      end
    end
  end

  def self.auto_send_notification_at_abolition_date
    Punishment
      .where(records_in_where: 'profile')
      .where(profile_punishment_status: 'in_effect')
      .where('profile_abolition_date = :date', date: Time.zone.now).each do |punishment|
      if Punishment
           .where(user_id: punishment.user_id)
           .where(records_in_where: 'profile')
           .where(profile_punishment_status: 'in_effect')
           .where('profile_abolition_date > :date', date: Time.zone.now)
           .empty?

        relation_group_users = Role.find_by(key: 'relation_group')&.users
        employee = User.find_by(id: punishment.user_id)
        Message.add_notification(punishment,
                                 'punishment_at_abolition_date',
                                 relation_group_users.pluck(:id).uniq,
                                 { employee: employee }) unless (relation_group_users.nil? || relation_group_users.empty?)
      end
    end
  end

  def get_json_data
    approval_item_data = self
                             .approval_items
                             .order(:created_at => :desc)
                             .as_json(include: :user)
    attachment_item_data = self
                               .attend_attachments
                               .order(:created_at => :desc)
                               .as_json(include: :creator)
    punishment_data = self.as_json(include: { user: { include: [:department, :position] }})
    punishment_data['approval_items']      = approval_item_data
    punishment_data['attend_attachments']    = attachment_item_data
    punishment_data['punishment_status']   = I18n.t('punishment.enum_punishment_status.'+punishment_data['punishment_status'])
    punishment_data['punishment_result']   = I18n.t('punishment.enum_punishment_result.'+punishment_data['punishment_result']) if punishment_data['punishment_result']
    punishment_data['tracker']             = User.find(self[:tracker_id])
    punishment_data
  end

  def dealing_with_language
    profile_punishment_status = I18n.t('punishment.profile_punishment_status.'+self.profile_punishment_status)
    punishment_result         = I18n.t('punishment.enum_punishment_result.'+self.punishment_result)
    punishment_data = self.as_json(include: :tracker)
    punishment_data['profile_punishment_status'] = profile_punishment_status
    punishment_data['punishment_result']         = punishment_result
    punishment_data
  end

  scope :by_punishment_status, lambda { |status|
    where(punishment_status: status)
  }

  scope :by_users_employee_no, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_users_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_users_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }

  scope :by_punishment_result, lambda { |result|
    where(punishment_result: result)
  }

end
