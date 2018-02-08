# == Schema Information
#
# Table name: jobs
#
#  id                :integer          not null, primary key
#  department_id     :integer
#  position_id       :integer
#  superior_email    :string
#  grade             :string
#  number            :integer
#  chinese_range     :text
#  english_range     :text
#  chinese_skill     :text
#  english_skill     :text
#  chinese_education :text
#  english_education :text
#  status            :integer          default("enabled")
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  region            :string
#  need_number       :integer
#
# Indexes
#
#  index_jobs_on_department_id  (department_id)
#  index_jobs_on_position_id    (position_id)
#

class Job < ApplicationRecord
  belongs_to :department
  belongs_to :position

  alias_attribute :key, :id
  enum status: { enabled: 0, disabled: 1 }
  before_save :compute_need_number, :toggle_status

  scope :of_region, ->(region_key) { where(region: region_key) }

  scope :by_region, -> (region){
    where(region: region) if region
  }

  def chinese_name
    begin
      "#{department.chinese_name} / #{position.chinese_name}"
    rescue
      ''
    end

  end

  def english_name
    begin
      "#{department.english_name} / #{position.english_name}"
    rescue
      ''
    end
  end

  def simple_chinese_name
    begin
      "#{department.simple_chinese_name} / #{position.simple_chinese_name}"
    rescue
      ''
    end

  end

  def self.enabled_jobs_count region_key
    self.of_region(region_key).enabled.count
  end

  def self.enabled_jobs_number_sum region_key
    self.of_region(region_key).enabled.sum(:need_number)
  end

  def self.profiles_plan_count region_key
    # self.profiles_count(region_key) + self.enabled_jobs_number_sum(region_key)
    self.of_region(region_key).sum(:number)
  end

  def self.profiles_count region_key
    # Profile.of_region(region_key).not_stashed.count
    self.of_region(region_key).map { |j| j.position.users.where(department_id: j.department_id).count }.sum
  end

  def self.statistics region_key
    {
      jobs_count: self.enabled_jobs_count(region_key),
      profiles_plan_count: self.profiles_plan_count(region_key),
      profiles_count: self.profiles_count(region_key),
      need_count: self.enabled_jobs_number_sum(region_key),
    }
  end

  def position_profiles_count
    # .joins(:profile).where(profiles: {is_stashed: false})
    self.position.users.where(department_id: department.id).count
  end

  def toggle_status
    self.status = self.need_number.to_i > 0 ? :enabled : :disabled
  end

  def compute_need_number
    job_need_number = 0
    job_need_number = self.number - self.position_profiles_count if self.position
    self.need_number = job_need_number >= 0 ? job_need_number : 0
  end

  def self.recaculate_need_number
    self.all.each do |j|
      j.compute_need_number
      j.toggle_status
      j.save
    end
  end

end
