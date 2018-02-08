# == Schema Information
#
# Table name: entry_lists
#
#  id                  :integer          not null, primary key
#  registration_time   :datetime
#  user_id             :integer
#  is_can_be_absent    :boolean
#  working_status      :integer
#  title_id            :integer
#  is_in_working_time  :integer
#  registration_status :integer
#  change_reason       :string
#  train_id            :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  creator_id          :integer
#
# Indexes
#
#  index_entry_lists_on_creator_id  (creator_id)
#  index_entry_lists_on_title_id    (title_id)
#  index_entry_lists_on_train_id    (train_id)
#  index_entry_lists_on_user_id     (user_id)
#

class EntryList < ApplicationRecord
  include StatementAble
  include EntryListValidators
  enum working_status: {on_duty: 0, leave: 1}
  enum is_in_working_time: {operating_hours: 0, non_working_time: 1, both_are: 2, to_define: 3}
  enum registration_status: {staff_registration: 0, department_registration: 1, invite_to_register: 2, invitation_to_be_confirmed: 3, cancel_the_registration: 4}
  validates :train_id, :creator_id, :user_id, :registration_status, presence: true
  validates_with EntryListWithUserLimitValidator, on: :create
  after_create :set_title
  belongs_to :user
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id'
  belongs_to :train
  belongs_to :title



  def set_title
    unless self.title_id
      self.update_columns(title_id: self.train.titles.first.id)
    end
  end
  scope :joins_for_show, lambda {
      joins( user: [:department, :position], creator: [:department, :location, :position]).left_outer_joins(:title)
  }

  scope :by_order, lambda{|sort_column, sort_direction|
    if sort_column == :course_name
      order(select_language => sort_direction)
    elsif sort_column == :creator_name
      order("creators_train_templates.#{select_language.to_s} #{sort_direction.to_s}")
    elsif sort_column == :empoid
      order("users.empoid #{sort_direction.to_s}")
    elsif sort_column == :name
      order("users.#{select_language.to_s} #{sort_direction.to_s}")
    elsif sort_column == :department_id
      order("users.department_id #{sort_direction.to_s}")
    elsif sort_column == :position_id
      order("users.position_id #{sort_direction.to_s}")
    elsif  sort_column == :creator_name
      order("creators_entry_lists.#{select_language.to_s} #{sort_direction.to_s}")
    elsif sort_column == :by_creator_department_id
      order("creators.department_id #{sort_direction.to_s} ")
    elsif sort_column == :by_creator_position_id
      order("creators.position_id #{sort_direction.to_s} ")
    elsif sort_column == :by_trainingSessions
      order("registration_status #{sort_direction.to_s} ")
    elsif sort_column == :by_isExeptionAbsence
      order("is_can_be_absent #{sort_direction.to_s} ")
    else
      order(sort_column => sort_direction)
    end
  }

  scope :by_registration_time, lambda {|registration_time_begin, registration_time_end|
    if registration_time_begin && registration_time_end
      where(registration_time: registration_time_begin...registration_time_end)
    elsif registration_time_begin
      where('registration_time > :registration_time_begin', registration_time_begin: registration_time_begin)
    elsif registration_time_end
      where('registration_time < :registration_time_begin', registration_time_begin: registration_time_begin)
    end
  }

  scope :by_train_id, lambda{|train_id|
    where(train_id: train_id) if train_id
  }

  scope :by_train_id_with_attend, lambda{|train_id|
    where(train_id: train_id, registration_status: %w(staff_registration department_registration invite_to_register)) if train_id
  }

  scope :by_title_id, lambda {|title_id|
    where(title_id: title_id) if title_id
  }

  scope :by_title_id_with_attend, lambda {|title_id|
    where(title_id: title_id, registration_status: %w(staff_registration department_registration invite_to_register)) if title_id
  }

  scope :by_empoid, lambda {|empoid|
    where(users: {empoid: empoid}) if empoid
  }

  scope :by_name, lambda{|name|
    where(users:{ select_language => name}) if name
  }

  scope :by_department_id, lambda {|department_id|
    where(users: {department_id: department_id}) if department_id
  }

  scope :by_position_id, lambda {|position_id|
    where(users: {position_id: position_id}) if position_id
  }

  scope :by_is_can_be_absent, lambda {|is_can_be_absent|
    where(is_can_be_absent: is_can_be_absent) if is_can_be_absent
  }

  scope :by_working_status, lambda {|working_status|
    where(working_status: working_status) if working_status
  }

  scope :by_title_id, lambda {|title_id|
      where(titles: {id: title_id})  if title_id
  }
  scope :by_is_in_working_time, lambda{|is_in_working_time|
    where(is_in_working_time: is_in_working_time) if is_in_working_time
  }

  scope :by_registration_status, lambda{|registration_status|
    where(registration_status: registration_status)  if registration_status
  }

  scope :by_not_registration_status, lambda{|not_registration_status|
    where.not(registration_status: not_registration_status)  if not_registration_status
  }

  scope :by_creator_name, lambda{|creator_name|
    where(creators_entry_lists: {select_language => creator_name})  if creator_name
  }

  scope :by_creator_department_id, lambda{|creator_department_id|
    where(departments_users:{id: creator_department_id}) if  creator_department_id
  }

  scope :by_creator_position_id, lambda {|creator_position_id|
    where(positions_users: {id: creator_position_id}) if creator_position_id
  }

  def update_by_department(params)
    if %w(staff_registration department_registration invite_to_register).include?(self.registration_status) && params[:registration_status] == 'cancel_the_registration'
      self.update(params.merge(change_reason: new_change_reason(params[:change_reason]), title_id: nil))
    elsif self.registration_status == 'invitation_to_be_confirmed' && params[:registration_status] == 'invite_to_register'
      self.update(params.merge(change_reason: new_change_reason(params[:change_reason])))
    elsif self.registration_status == 'cancel_the_registration' && params[:registration_status]  == 'department_registration'
      self.update(params.merge(change_reason: new_change_reason(params[:change_reason])))
    end
  end

  def self.create_with_params(user_id, title_id, operation = nil, current_user_id , train_id)
    entry_list = nil
    ActiveRecord::Base.transaction do
      title =  Title.find(title_id) rescue nil
      Message.add_notification(Train.find(train_id), 'by_invited', user_id) if operation ==  'by_invited'
      entry_list = self.create!(user_id: user_id, train_id: train_id, registration_status: EntryListService.get_registration_status(operation), registration_time: Time.zone.now, creator_id: current_user_id, title_id: title&.id, is_can_be_absent: TrainingService.is_can_be_absent(User.find(user_id)) )

    end
    entry_list.try(:id)
  end


  def self.create_with_params_by_department(user_id, title_id, current_user_id, train_id, change_reason)
    entry_list = nil
    ActiveRecord::Base.transaction do
      title =  Title.find(title_id) rescue nil
      entry_list = self.create!(user_id: user_id, train_id: train_id, registration_status: 1, registration_time: Time.zone.now, creator_id: current_user_id, title_id: title&.id, is_can_be_absent: TrainingService.is_can_be_absent(User.find(user_id)), change_reason: change_reason )
    end
    entry_list.try(:id)
  end



def update_with_params(change_reason, title_id, operator = nil , edit_action)

    if operators.include? (operator)
      if edit_action ==  'cancel'
        self.update(registration_status: 'cancel_the_registration', change_reason: new_change_reason(change_reason))
      elsif edit_action ==  'update_title'
        self.update(title_id: title_id, change_reason: new_change_reason(change_reason))
      elsif edit_action == 'accept'
        self.update(registration_status: 'invite_to_register')
      end
    end
  end

  def update_by_hr(params)
      self.update(params.merge(change_reason: new_change_reason(params[:change_reason])))
  end

  def self.update_params
    %w(registration_status change_reason title_id)
  end

  def self.title_options(train_id)
    Title.where(id: self.joins(train: :titles).where(train_id: train_id).select('titles.id')).as_json.map do|item|
      item['english_name'] = item['simple_chinese_name'] =  item['chinese_name'] = item['name']
      item
    end
  end

  def self.department_options(train_id)
    Department.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.department_id'))
  end

  def self.position_options(train_id)
    Position.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.position_id'))
  end

  def self.creator_department_options(train_id)
    Department.where(id: self.joins(:creator, :train).where(train_id: train_id).select('users.department_id'))
  end

  def self.creator_position_options(train_id)
    Position.where(id: self.joins(:creator, :train).where(train_id: train_id).select('users.position_id'))
  end

  def working_status
    if  self.train.status ==  'completed'
      self.attributes['working_status']
    else
      if self.user
        if ProfileService.is_leave?(self.user)
        'leave'
        else
        'on_duty'
        end
      else
        'leave'
      end
    end
  end

  def is_can_be_absent
    if  self.train.status ==  'completed'
      self.attributes["is_can_be_absent"]
    elsif self.user
      TrainingService.is_can_be_absent(self.user)
    else
      false
    end
  end

  def is_in_working_time
    'both_are'
  end

  private

  def new_change_reason(change_reason)
    if self.change_reason.to_s.empty?
      change_reason
    else
      self.change_reason.to_s + ',' + change_reason
    end
  end

  def operators
    if %w(by_employee by_employee_and_department).include? self.train.registration_method
      %W(hr employee)
    else
      %w(hr)
    end
  end

end
