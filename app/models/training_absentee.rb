# == Schema Information
#
# Table name: training_absentees
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  train_class_id       :integer
#  has_submitted_reason :boolean
#  has_been_exempted    :boolean
#  absence_reason       :string
#  submit_date          :datetime
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_training_absentees_on_train_class_id  (train_class_id)
#  index_training_absentees_on_user_id         (user_id)
#
# Foreign Keys
#
#  fk_rails_42a6e1425a  (train_class_id => train_classes.id)
#  fk_rails_827cbe54e5  (user_id => users.id)
#

class TrainingAbsentee < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :train_class
  has_one :train, through: :train_class
  has_one :title, through: :train_class

  scope :order_employee_name, lambda{|args|
    sort_direction = args.first
    order("users.#{select_language} #{sort_direction}") if sort_direction
  }

  scope :by_name, lambda{|name|
    where(users:{ select_language => name}) if name
  }

  scope :by_train_name, -> (train_id) {
    where(train_classes: {train_id: train_id} ) if train_id
  }

  scope :by_train_number, ->(number) {
    where('trains.train_number = :number', number: number)
  }

  scope :by_train_date, ->(train_date) {
    from = (Time.zone.parse(train_date['begin']).beginning_of_day rescue nil)
    to   = (Time.zone.parse(train_date['end']).end_of_day rescue nil)
    if from && to
      includes(:train).where('trains.train_date_end >= :from AND trains.train_date_begin <= :to', from: from, to: to)
    elsif from
      includes(:train).where('trains.train_date_end >= :from', from: from)
    elsif to
      includes(:train).where('trains.train_date_begin <= :to', to: to)
    end
  }

  scope :by_train_class_time, ->(class_date) {
    from = (Time.zone.parse(class_date['begin']).beginning_of_day rescue nil)
    to   = (Time.zone.parse(class_date['end']).end_of_day rescue nil)
    if from && to
      includes(:train_class).where('train_classes.time_end >= :from AND train_classes.time_begin <= :to', from: from, to: to)
    elsif from
      includes(:train_class).where('train_classes.time_end >= :from', from: from)
    elsif to
      includes(:train_class).where('train_classes.time_begin <= :to', to: to)
    end
  }

  def self.create_with_params(user, sign_list)
    TrainingAbsentee.create(user_id: user.id, train_class_id: sign_list.train_class_id, has_submitted_reason: false, has_been_exempted: false) unless sign_list.sign_status == 'attend' || ProfileService.is_leave?(user)
  end


  class << self
    def extra_joined_association_names
      [{user: [:department, :position]}, {train_class: [:train, :title]}]
    end

    def train_name_options
      Train.all
    end

    def detail_by_id(id)
      TrainingAbsentee
          .includes(:user)
          .includes(train_class: [:title, :train])
          .find(id)
    end
  end

  def self.get_user_status(user)
    if TrainingAbsentee.where(user_id: user.id, has_submitted_reason: false).count > 0
      #需要填写缺席原因
      Config.get(:constants_collection)['TrainingAbsentee']['need_to_fill_reason']
    elsif TrainingAbsentee.where(user_id: user.id, has_submitted_reason: true, has_been_exempted: false).count > 0
      #需要等待审核
      Config.get(:constants_collection)['TrainingAbsentee']['waiting']
    else
      #没问题
      Config.get(:constants_collection)['TrainingAbsentee']['ok']
    end

  end

  def decorate_train_date
    "#{self.train.train_date_begin.strftime('%Y/%m/%d')} ~ #{self.train.train_date_end.strftime('%Y/%m/%d')}"
  end

  def decorate_train_class_time
    "#{self.title.name}) #{self.train_class.time_begin.strftime('%Y/%m/%d')} #{I18n.t('training_absentees.'+self.train_class.time_begin.strftime('%A'))} #{self.train_class.time_begin.strftime('%H:%M')}-#{self.train_class.time_end.strftime('%H:%M')}"
  end

  def get_xlsx_data_row
    record = self.as_json(include: [
        { user: { include: [:department, :position] } },
        { train_class: { include: [:train, :title] } }
    ])
    one_record = {}
    one_record[:employee_id]          = record.dig('user.empoid')
    if I18n.locale==:en
      one_record[:employee_name]      = record.dig 'user.english_name'
      one_record[:department]         = record.dig 'user.department.english_name'
      one_record[:position]           = record.dig 'user.position.english_name'
      one_record[:train_name]         = record.dig 'train_class.train.english_name'
    elsif I18n.locale==:'zh-CN'
      one_record[:employee_name]      = record.dig 'user.simple_chinese_name'
      one_record[:department]         = record.dig 'user.department.simple_chinese_name'
      one_record[:position]           = record.dig 'user.position.simple_chinese_name'
      one_record[:train_name]         = record.dig 'train_class.train.simple_chinese_name'
    else
      one_record[:employee_name]      = record.dig 'user.chinese_name'
      one_record[:department]         = record.dig 'user.department.chinese_name'
      one_record[:position]           = record.dig 'user.position.chinese_name'
      one_record[:train_name]         = record.dig 'train_class.train.chinese_name'
    end
    one_record[:train_number]         = record.dig 'train_class.train.train_number'
    one_record[:train_date]           = self.decorate_train_date
    one_record[:has_submitted_reason] = I18n.t('training_absentees.has_submitted_reason.'+record.dig('has_submitted_reason').to_s)
    one_record[:has_been_exempted]    = I18n.t('training_absentees.has_been_exempted.'+record.dig('has_been_exempted').to_s)
    one_record[:train_class_time]     = self.decorate_train_class_time
    if record.dig('absence_reason')
      one_record[:absence_reason]     = record.dig('absence_reason')
    else
      one_record[:absence_reason]     = ' '
    end
    if record.dig('submit_date')
      one_record[:submit_date]        = record.dig('submit_date').strftime('%Y/%m/%d %H:%M')
    else
      one_record[:submit_date]        = ' '
    end
    one_record
  end

end
