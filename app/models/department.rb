# == Schema Information
#
# Table name: departments
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  comment             :text
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :integer          default("enabled")
#  head_id             :integer
#  simple_chinese_name :string
#
# Indexes
#
#  index_departments_on_head_id    (head_id)
#  index_departments_on_parent_id  (parent_id)
#

class Department < ApplicationRecord
  has_closure_tree
  has_and_belongs_to_many :locations
  has_and_belongs_to_many :positions
  has_and_belongs_to_many :groups
  has_many :users
  has_and_belongs_to_many :trains
  has_and_belongs_to_many :train_classes
  has_many :rosters
  has_many :attendances

  belongs_to :head, class_name: 'User'

  has_many :employees, class_name: 'User'
  has_many :jobs

  has_many :select_cloumn_templates

  include TreeAble
  enum status: [:enabled, :disabled]

  after_save :recreate_bonus_element_settings

  scope :without_suncity_department, lambda{
    where.not(id: 1)
  }

  def self.load_predefined
    self.find_or_create_by(id: 1) do |dep|
      dep.chinese_name = '太陽城集團行政總裁兼董事'
      dep.english_name = 'CEO of Suncity Group'
      dep.simple_chinese_name = '太阳城集团行政总裁兼董事'
      dep.comment = '初始創建的部門'
      dep.region_key = 'macau'
      dep.location_ids = Location.where(location_type: :office).ids
    end
  end

  def key
    id.to_s
  end

  def region
    region_key
  end

  def employees_count
    if (employees.count == 0)&&(!(self.children.empty?))
      count = 0
      self.children.each{|record|
        count += record.employees.count
      }
      count
    else
      employees.count
    end
  end

  def positions_count
    positions.count
  end

  def recreate_bonus_element_settings
    BonusElement.recreate_all_settings
    AppraisalDepartmentSetting.create_department_setting
  end

  def users_entry_lists(train_id)
    self.users.map{|user|
      entry_list =  user.entry_lists.by_train_id(train_id).first
      if entry_list
        user.as_json(include: [:position, :department, :location]).merge(entry_list.as_json(include: {title: {except: :id}}, except: :id))
      else
        user.as_json(include: [:position, :department, :location])
      end
    }
  end

  def heads
    grade = get_highest_grade
    if grade
      self.users.where(grade: grade)
    end
  end

  def get_highest_grade
    self.users.order(grade: :asc).first&.grade
  end

end
