# == Schema Information
#
# Table name: final_lists
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  working_status        :integer
#  cost                  :decimal(15, 2)
#  train_result          :integer
#  attendance_percentage :decimal(15, 2)
#  test_score            :decimal(15, 2)
#  train_id              :integer
#  entry_list_id         :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  comment               :string
#
# Indexes
#
#  index_final_lists_on_entry_list_id  (entry_list_id)
#  index_final_lists_on_train_id       (train_id)
#  index_final_lists_on_user_id        (user_id)
#

class FinalList < ApplicationRecord
  include StatementAble
  enum working_status: {on_duty: 0, leave: 1}
  enum train_result: {train_pass: 0, train_not_pass: 1, train_leave: 2 }
  belongs_to :train
  belongs_to :entry_list
  belongs_to :user
  has_and_belongs_to_many :train_classes


  scope :joins_for_show, lambda {
    joins( user: [:department, :position])
  }

  scope :by_order, lambda{|sort_column, sort_direction|
    if sort_column == :empoid
      order("users.empoid #{sort_direction}")
    elsif sort_column == :name
      order("users.#{select_language.to_s} #{sort_direction.to_s}")
    elsif sort_column == :department_id
      order("users.department_id #{sort_direction.to_s}")
    elsif sort_column == :position_id
      order("users.position_id #{sort_direction.to_s}")
    else
      order(sort_column => sort_direction)
    end
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

  scope :by_working_status, lambda {|working_status|
    where(working_status: working_status) if working_status
  }

  scope :by_cost, lambda {|cost|
    where(cost: cost) if cost
  }

  scope :by_train_result, lambda {|train_result|
    where(train_result: train_result) if train_result
  }

  scope :by_attendance_percentage, lambda {|attendance_percentage|
    where(attendance_percentage: attendance_percentage) if attendance_percentage
  }

  scope :by_test_score, lambda {|test_score|
    where(test_score: test_score) if test_score
  }

  def working_status
    if  self.train.status ==  'completed'
      self.attributes['working_status']
    else
      if ProfileService.is_leave?(self.user)
        'leave'
      else
        'on_duty'
      end
    end
  end

  def test_score
    TrainingService.calcul_test_score(self.train, self.user)
  end

  def attendance_percentage
    if  self.train.status ==  'completed'
      self.attributes['attendance_percentage']
    else
      TrainingService.calcul_attend_percentage(self.train, self.user)
    end
  end

  def self.department_options(train_id)
    Department.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.department_id'))
  end

  def self.position_options(train_id)
    Position.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.position_id'))
  end

  def self.train_class_options(train_id)
    TrainClass.where(train_id: train_id).joins(:title).map do |item|
      res_begin = item.time_begin
      if res_begin.nil?
        res_begin_simple_chinese_name =res_begin_english = res_begin_chinese = nil
      else
        res_begin_chinese = I18n.l(res_begin, format: '%Y/%m/%d %A %H:%M', locale: :'zh-HK')
        res_begin_english = I18n.l(res_begin, format: '%Y/%m/%d %A %H:%M', locale: :en)
        res_begin_simple_chinese_name = I18n.l(res_begin, format: '%Y/%m/%d %A %H:%M', locale: :'zh-CN')
      end

      res_end = item.time_end
      if res_end.nil?
        res_end_simple_chinese_name =res_end_english = res_end_chinese = nil
      else
        res_end_chinese = I18n.l(res_end, format: '%H:%M', locale: :'zh-HK')
        res_end_english = I18n.l(res_end, format: '%H:%M', locale: :en)
        res_end_simple_chinese_name = I18n.l(res_end, format: '%H:%M', locale: :'zh-CN')
      end
      item.as_json(include: :title).merge({
          chinese_name: "#{item&.title&.name}) #{res_begin_chinese.to_s}-#{res_end_chinese.to_s}",
          english_name:"#{item&.title&.name}) #{res_begin_english.to_s}-#{res_end_english.to_s}",
          simple_chinese_name:"#{item&.title&.name}) #{res_begin_simple_chinese_name.to_s}-#{res_end_simple_chinese_name.to_s}",
                 })
    end

  end

  def self.extra_columns_options(train_id)
    return {} unless train_id
    train = Train.find(train_id)
    rows = []
    train.train_classes.maximum(:row).times do |i|
      rows.push({
          key: 1+i,
          chinese_name: Config.get(:constants_collection)['RowTranslation'][(i+1)]['chinese_name'],
          english_name: Config.get(:constants_collection)['RowTranslation'][(i+1)]['english_name'],
          simple_chinese_name: Config.get(:constants_collection)['RowTranslation'][(i+1)]['simple_chinese_name'],
          value_type: 'string_value',
          data_index: "train_classes.#{i}.id",
          sorter: true,
          search_type: 'screen',
          options_type: 'options',
          options_action: 'train_class_options',
          search_attribute: 'train_class_id'
                })
    end
    {
        insert: [4].concat(rows)
    }
  end

  def update_result(params)
    tag1, tag2 = true, true

    if %w(train_pass train_not_pass).include?(params['train_result'])

      tag1 = self.update(train_result: params['train_result'])
    end
    if  self.train.status == 'training'
      tag2 = self.update(comment: params['comment'] )
    end
    tag1 && tag2
  end


end
