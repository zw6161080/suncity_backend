# == Schema Information
#
# Table name: work_experences
#
#  id                                   :integer          not null, primary key
#  company_organazition                 :string
#  work_experience_position             :string
#  job_description                      :string
#  work_experience_salary               :integer
#  work_experience_reason_for_leaving   :string
#  work_experience_company_phone_number :integer
#  former_head                          :string
#  work_experience_email                :string
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  work_experience_from                 :datetime
#  work_experience_to                   :datetime
#  profile_id                           :integer
#  creator_id                           :integer
#
# Indexes
#
#  index_work_experences_on_creator_id  (creator_id)
#  index_work_experences_on_profile_id  (profile_id)
#

class WorkExperence < ApplicationRecord
  include StatementAble
  belongs_to :profile
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  validates :creator_id, :company_organazition, :work_experience_position, :work_experience_from, :work_experience_to, presence:  true

  scope :by_work_begin_and_end, lambda { |work_experience_from, work_experience_to|
    where.not('(work_experience_to IS NOT NULL AND work_experience_to <= :work_experience_from) OR work_experience_from > :work_experience_to ',
              work_experience_from: work_experience_from,
              work_experience_to: work_experience_to)
  }

  scope :by_work_date, lambda { |date|
    where('work_experience_from <= :date AND (work_experience_to IS NULL OR work_experience_to >= :date)', date: date)
  }

  scope :by_company_name, -> (company_name) {
    where(:users => { company_name: company_name })
  }

  scope :by_location, -> (location) {
    where(:users => { location_id: location })
  }

  scope :by_department, -> (department) {
    where(:users => { department_id: department })
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid              then order("users.empoid #{sort_direction}")
      when :name                then order("users.chinese_name #{sort_direction}")
      when :location            then order("users.location_id #{sort_direction}")
      when :department          then order("users.department_id #{sort_direction}")
      when :position            then order("users.position_id #{sort_direction}")
      when :date_of_employment  then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
        end
      when :leave_date          then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, resigned_date}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, resigned_date}' ")
        end
    end
  }



  def add_row(params, current_user=nil)
    self.assign_attributes(params)
    self.creator = current_user
    self.save
  end

  def self.joined_query(param_id = nil)
    self.left_outer_joins(
        [].concat(extra_joined_association_names)
    )
  end
end
