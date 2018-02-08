# == Schema Information
#
# Table name: education_informations
#
#  id                      :integer          not null, primary key
#  college_university      :string
#  educational_department  :string
#  graduate_level          :string
#  diploma_degree_attained :string
#  certificate_issue_date  :date
#  graduated               :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  from_mm_yyyy            :datetime
#  to_mm_yyyy              :datetime
#  profile_id              :integer
#  creator_id              :integer
#  highest                 :boolean
#
# Indexes
#
#  index_education_informations_on_creator_id  (creator_id)
#  index_education_informations_on_profile_id  (profile_id)
#

class EducationInformation < ApplicationRecord
  include StatementAble
  belongs_to :profile
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  validates :from_mm_yyyy, :to_mm_yyyy, :college_university, :educational_department, :graduate_level, :creator_id, presence: true
  validates :graduated, inclusion: {in: [false, true]}

  scope :by_education_from_and_to, lambda { |from_mm_yyyy, to_mm_yyyy|
    where.not('(to_mm_yyyy IS NOT NULL AND to_mm_yyyy <= :from_mm_yyyy) OR from_mm_yyyy > :to_mm_yyyy ',
              from_mm_yyyy: from_mm_yyyy,
              to_mm_yyyy: to_mm_yyyy)
  }

  scope :by_work_date, lambda { |date|
    where('from_mm_yyyy <= :date AND (to_mm_yyyy IS NULL OR to_mm_yyyy >= :date)', date: date)
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
