# == Schema Information
#
# Table name: sign_lists
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  train_class_id :integer
#  final_list_id  :integer
#  sign_status    :integer
#  comment        :string
#  working_status :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  train_id       :integer
#
# Indexes
#
#  index_sign_lists_on_final_list_id   (final_list_id)
#  index_sign_lists_on_train_class_id  (train_class_id)
#  index_sign_lists_on_train_id        (train_id)
#  index_sign_lists_on_user_id         (user_id)
#

class SignList < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :title
  belongs_to :train_class
  belongs_to :final_list
  belongs_to :train
  enum sign_status: {attend: 0, absence: 1, has_leave: 2}
  enum working_status: {on_duty: 0, leave: 1}

  def self.title_options(train_id)
    Title.where(train_id: train_id).as_json.map do|item|
      item['english_name'] = item['simple_chinese_name'] =  item['chinese_name'] = item['name']
      item
    end
  end

  def self.train_class_options(train_id)
    TrainClass.where(train_id: train_id).map do |item|
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
      item.as_json.merge({
                                              chinese_name: "#{res_begin_chinese.to_s}-#{res_end_chinese.to_s}",
                                              english_name:"#{res_begin_english.to_s}-#{res_end_english.to_s}",
                                              simple_chinese_name:"#{res_begin_simple_chinese_name.to_s}-#{res_end_simple_chinese_name.to_s}",
                                          })
    end
  end

  def self.department_options(train_id)
    Department.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.department_id'))
  end

  def self.position_options(train_id)
    Position.where(id: self.joins(:user, :train).where(train_id: train_id).select('users.position_id'))
  end

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
  def sign_status
    if self.working_status == 'leave'
      'has_leave'
    else
      self.attributes['sign_status']
    end
  end

  scope :joins_for_show, lambda {
    joins( user: [:department, :position], train_class: :title)
  }


  scope :by_order, lambda{|sort_column, sort_direction|
    if sort_column == :empoid
      order("users.empoid #{sort_direction.to_s}")
    elsif sort_column == :name
      order("users.#{select_language.to_s} #{sort_direction.to_s}")
    elsif sort_column == :department_id
      order("users.department_id #{sort_direction.to_s}")
    elsif sort_column == :position_id
      order("users.position_id #{sort_direction.to_s}")
    elsif sort_column == :title_id
      order("train_classes.title_id #{sort_direction.to_s}")
    elsif sort_column == :train_class
      if sort_direction == :desc
        order("train_classes.time_begin DESC")
      else
        order("train_classes.time_begin ASC")
      end
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

  scope :by_title_id, lambda{|title|
    where(train_classes: {title_id: title}) if title
  }

  scope :by_train_class_id, lambda {|train_class_id|
    where(train_class_id: train_class_id)    if train_class_id
  }

  scope :by_working_status, lambda {|working_status|
    where(working_status: working_status)  if working_status
  }

  scope :by_sign_status, lambda {|sign_status|
    where(sign_status: sign_status) if sign_status
  }


  def update_with_params(update_params, operator)
    if operator == 'hr'
      self.update(update_params)

      train = Train.find(self.train_id)
      user = User.find(self.user_id)
      update_training_paper(train, user)
      update_supervisor_assessment(train, user)
    end
  end

  def update_training_paper(train, user)
    tp = TrainingPaper.where(train_id: train.id, user_id: user.id).first
    if tp
      tp.attendance_rate = TrainingService.calcul_attend_percentage(train, user).truncate(2).to_s("F").to_f*100
      tp.save!
    end
  end

  def update_supervisor_assessment(train, user)
    sa = SupervisorAssessment.where(train_id: train.id, user_id: user.id).first
    if sa
      sa.attendance_rate = TrainingService.calcul_attend_percentage(train, user).truncate(2).to_s("F").to_f*100
      sa.save!
    end
  end
end
