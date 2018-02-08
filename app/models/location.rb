# == Schema Information
#
# Table name: locations
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  simple_chinese_name :string
#  location_type       :string           default("vip_hall")
#
# Indexes
#
#  index_locations_on_parent_id  (parent_id)
#

class Location < ApplicationRecord
  has_closure_tree
  has_and_belongs_to_many :departments
  has_and_belongs_to_many :positions
  has_and_belongs_to_many :users
  has_many :rosters
  has_many :attendances
  has_many :location_statuses, dependent: :destroy
  has_many :location_department_statuses, dependent: :destroy
  has_many :employees, class_name: 'User'
  include TreeAble
  validates :location_type, inclusion: {in: %w(vip_hall office others)}
  after_save :recreate_bonus_element_settings
  #排除贵宾厅
  scope :list, -> {}


  def self.to_tree
    [
      {
        id: Location.find_by_location_type(:office)&.id,
        key: :office,
        children: []
      },
      {
        id: :vip_hall,
        key: :vip_hall,
        children: Location.where(location_type: :vip_hall),
      },
      {
        id: :others,
        key: :others,
        children: Location.where(location_type: :others),
      }
    ]
  end

  def can_be_destroyed_on_tree?
    (self.location_type != 'office' && CareerRecord.where(location_id: self.id).empty? && (LentRecord.where(original_hall_id: self.id).or(LentRecord.where(temporary_stadium_id: self.id))).empty? && MuseumRecord.where(location_id: self.id).empty?) && self.employees.empty?
  end

  def can_be_updated_on_tree?
    (self.location_type != 'office' )
  end


  def self.load_predefined
    self.find_or_create_by(typ: 'office') do |loc|
      loc.chinese_name = '辦公室'
      loc.english_name = 'OFFICE'
      loc.simple_chinese_name = '办公室'
      loc.region_key = 'macau'
      loc.location_type = 'office'
    end
  end

  def key
    id.to_s
  end

  def employees_count
    employees.count
  end

  def employees_count_on_duty_this_month
    ProfileService.employees_on_duty_this_month.count
  end

  def employees_left_this_month

  end

  def recreate_bonus_element_settings
    BonusElement.recreate_all_settings
  end

  def self.with_departments
    self
      .includes(:departments)
      .where('departments.status' => 0)
      .where('departments.id != 1')
      .as_json(
        include: {
          departments: {methods: :employees_count}
        },
        methods: :employees_count
      )
  end

  def self.model_with_departments
    self
      .includes(:departments)
      .where('departments.status' => 0)
      .where('departments.id != 1')
  end

end
