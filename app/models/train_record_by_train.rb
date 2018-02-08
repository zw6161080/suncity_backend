# == Schema Information
#
# Table name: train_record_by_trains
#
#  id               :integer          not null, primary key
#  train_id         :integer
#  final_list_count :integer
#  entry_list_count :integer
#  invited_count    :integer
#  attendance_rate  :decimal(10, 2)
#  passing_rate     :decimal(10, 2)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_train_record_by_trains_on_train_id  (train_id)
#
# Foreign Keys
#
#  fk_rails_f84c1137be  (train_id => trains.id)
#

class TrainRecordByTrain < ApplicationRecord
  belongs_to :train

  validates :train_id, presence: true

  def self.create_after_train_complete(train)
    TrainRecordByTrain.create(train_id: train.id, final_list_count: train.final_lists_count, entry_list_count: train.entry_lists_count, invited_count: invited_count(train), attendance_rate: attendance_rate(train), passing_rate: passing_rate(train))
  end

  def self.invited_count(train)
    train.final_lists.joins(:entry_list).where(entry_lists: {registration_status: 'invite_to_register' }).count
  end


  def self.attendance_rate(train)
    BigDecimal(SignList.where(train_id: train.id, sign_status: :attend).count) /  SignList.where(train_id: train.id).count
  end

  def self.passing_rate(train)
    BigDecimal(train.final_lists.where(train_result: :train_pass).count) / train.final_lists_count
  end

  def satisfaction_degree
    self.train.calcul_satisfaction_percentage
  end

  def self.options
    query = self.left_outer_joins(train: :train_template_type)
    {
        train_id: query.select('trains.id, trains.chinese_name, trains.english_name, trains.simple_chinese_name').distinct.as_json,
        train_type: query.select('train_template_types.id, train_template_types.chinese_name, train_template_types.english_name, train_template_types.simple_chinese_name').distinct.as_json
    }
  end

  def get_json_data
    self.as_json(include: {train: {include: :train_template_type}}, methods: :satisfaction_degree)
  end

  scope :by_train_id, ->(train_id) {
    where(train_id: train_id)
  }

  scope :by_train_number, ->(number) {
    includes(:train).where(trains: {train_number: number})
  }

  scope :by_train_date, ->(train_date) {
    from = (Time.zone.parse(train_date['begin']).beginning_of_day rescue nil)
    to   = (Time.zone.parse(train_date['end']).end_of_day rescue nil)
    if from && to
      joins(:train).where('trains.train_date_end >= :from AND trains.train_date_begin <= :to', from: from, to: to)
    elsif from
      joins(:train).where('trains.train_date_end >= :from', from: from)
    elsif to
      joins(:train).where('trains.train_date_begin <= :to', to: to)
    end
  }

  scope :by_train_type, ->(train_template_type_id) {
    where(train_id:
              Train.where(train_template_id:
                              TrainTemplate.where(train_template_type_id: train_template_type_id).select(:id)
              ).select(:id)
    )
  }

  scope :by_train_cost, ->(train_cost) {
    includes(:train).where(trains: {train_cost: train_cost})
  }

  scope :by_final_list_count, ->(final_list_count) {
    where(final_list_count: final_list_count)
  }

  scope :by_entry_list_count, ->(entry_list_count) {
    where(entry_list_count: entry_list_count)
  }

  scope :by_invited_count, ->(invited_count) {
    where(invited_count: invited_count)
  }

  scope :by_attendance_rate, ->(attendance_rate) {
    where(attendance_rate: attendance_rate)
  }

  scope :by_passing_rate, ->(passing_rate) {
    where(passing_rate: passing_rate)
  }

  scope :by_satisfaction_degree, ->(satisfaction_degree) {
    where(trains: {satisfaction_percentage: satisfaction_degree })
  }

end
