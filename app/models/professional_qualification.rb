# == Schema Information
#
# Table name: professional_qualifications
#
#  id                       :integer          not null, primary key
#  profile_id               :integer
#  professional_certificate :string
#  orgnaization             :string
#  issue_date               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_professional_qualifications_on_profile_id  (profile_id)
#
# Foreign Keys
#
#  fk_rails_4113f8f558  (profile_id => profiles.id)
#

class ProfessionalQualification < ApplicationRecord
  include StatementAble
  belongs_to :profile

  def self.create_records(profile, records)
    records.each do |record|
      professional_qualification = self.new(record.permit(:profile_id, :professional_certificate, :orgnaization, :issue_date).merge(profile_id: profile.id))
      professional_qualification.save!
    end
  end

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

end
