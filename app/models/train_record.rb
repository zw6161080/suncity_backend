# == Schema Information
#
# Table name: train_records
#
#  id                             :integer          not null, primary key
#  empoid                         :string
#  chinese_name                   :string
#  english_name                   :string
#  simple_chinese_name            :string
#  department_chinese_name        :string
#  department_english_name        :string
#  department_simple_chinese_name :string
#  position_chinese_name          :string
#  position_english_name          :string
#  position_simple_chinese_name   :string
#  train_result                   :boolean
#  attendance_rate                :decimal(15, 2)
#  train_id                       :integer
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  cost                           :decimal(15, 2)
#
# Indexes
#
#  index_train_records_on_train_id  (train_id)
#

class TrainRecord < ApplicationRecord
  belongs_to :train

  def self.create_train_records(train)
    train.final_lists.each do |item|
      user = item.user
      TrainRecord.create(empoid: user.empoid, chinese_name: user.chinese_name, english_name: user.english_name, simple_chinese_name: user.simple_chinese_name, department_chinese_name: user.department&.chinese_name, department_english_name: user.department&.english_name, department_simple_chinese_name: user.department&.simple_chinese_name,
      position_chinese_name: user.position&.chinese_name, position_english_name: user.position&.english_name, position_simple_chinese_name: user.position&.simple_chinese_name, train_result: train_result(train, user), attendance_rate: attendance_rate(train, user), cost: cost(train, user), train_id: train.id)
    end
  end

  def self.train_result(train, user)
    TrainingService.calcul_train_result(train, user)
  end

  def self.attendance_rate(train, user)
    TrainingService.calcul_attend_percentage(train, user)
  end

  def self.cost(train, user)
    FinalList.where(train_id: train.id, user_id: user.id).first&.cost
  end

  scope :join_train_train_template_train_template_type, lambda {
    joins(train:  :train_template_type)
  }

  scope :join_train, lambda {
    joins(:train)
  }

  scope :by_empoid, lambda { |empoid|
    where(train_records: {empoid: empoid})
  }

  scope :by_name, lambda { |name|
    where(train_records: {select_language => name})
  }

  scope :by_department_name, lambda { |department_name|
    where(train_records: {"department_#{select_language.to_s}".to_sym => department_name})
  }

  scope :by_position_name, lambda { |position_name|
    where(train_records: {"position_#{select_language.to_s}".to_sym => position_name})
  }

  scope :by_train_result, lambda { |train_result|
    where(train_records: {train_result: train_result})
  }

  scope :by_train_id, lambda { |id|
    where(trains: {id: id})
  }

  scope :by_train_number, lambda { |train_number|
    where(trains: {train_number: train_number})
  }

  scope :by_train_type, lambda { |id|
    where(trains: {train_template_type_id: id})
  }

  scope :by_train_cost, lambda { |train_cost|
    where(cost: train_cost)
  }

  scope :by_attendance_rate, lambda { |attendance_rate|
    where(attendance_rate: attendance_rate)
  }

  scope :order_by, lambda {|sort_column, sort_direction|
    case sort_column
      when :empoid            then reorder("train_records.empoid #{sort_direction}")
      when :name              then reorder("train_records.#{select_language.to_s} #{sort_direction}")
      when :department        then reorder("train_records.department_#{select_language.to_s} #{sort_direction}")
      when :position          then reorder("train_records.position_#{select_language.to_s} #{sort_direction}")
      when :train_name        then reorder("trains.#{select_language.to_s} #{sort_direction}")
      when :train_number      then reorder("trains.train_number #{sort_direction}")
      when :train_cost        then reorder("trains.train_cost #{sort_direction}")
      when :train_result      then reorder("train_records.train_result #{sort_direction}")
      when :date_of_train     then reorder("trains.train_date_begin #{sort_direction}")
      when :train_type        then reorder("trains.train_template_type_id #{sort_direction}")
      when :attendance_rate   then reorder("train_records.attendance_rate #{sort_direction}")
      else order(sort_column => sort_direction)
    end

  }

  scope :by_date_of_train, lambda { |from, to|
    if from && to
      where("trains.train_date_begin >= :from", from: from)
          .where("trains.train_date_end <= :to", to: to)
    elsif from
      where("trains.train_date_begin >= :from", from: from)
    elsif to
      where("trains.train_date_end <= :to", to: to)
    end
  }

  def self.field_options_all_records
    train_record_query = self.left_outer_joins(train:  :train_template_type)
    query_id = []
    department_names = []
    train_record_query.find_each do |record|
      unless department_names.include? record.department_chinese_name
        department_names.push record.department_chinese_name
        query_id.push record.id
      end
    end
    departments = []
    positions = []
    query_id.each do |id|
      departments << {
          key: TrainRecord.find(id)["department_#{select_language}"],
          chinese_name: TrainRecord.find(id).department_chinese_name,
          english_name: TrainRecord.find(id).department_english_name,
          simple_chinese_name: TrainRecord.find(id).department_simple_chinese_name,
      }.as_json

      positions << {
          key: TrainRecord.find(id)["position_#{select_language}"],
          chinese_name: TrainRecord.find(id).position_chinese_name,
          english_name: TrainRecord.find(id).position_english_name,
          simple_chinese_name: TrainRecord.find(id).position_simple_chinese_name,
      }.as_json
    end
    train_names = train_record_query.select(:train_id).distinct.map{|item|Train.find(item[:train_id])}.as_json(only:[:id, :chinese_name, :english_name, :simple_chinese_name])
    train_template_types = train_record_query.select("train_template_types.id").distinct.map{|item|TrainTemplateType.find(item[:id])}.as_json(only:[:id, :chinese_name, :english_name, :simple_chinese_name])
    train_results = [{"key"=>true, "chinese_name"=>"通過", "english_name"=>"Pass", "simple_chinese_name"=>"通过"}, {"key"=>false, "chinese_name"=>"未通過", "english_name"=>"Failed", "simple_chinese_name"=>"未通过"}]
    return {
        departments: departments,
        positions: positions,
        train_names: train_names,
        train_template_types: train_template_types,
        train_results: train_results
    }
  end

end
