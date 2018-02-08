# == Schema Information
#
# Table name: performance_interviews
#
#  id                           :integer          not null, primary key
#  appraisal_id                 :integer
#  appraisal_participator_id    :integer
#  interview_date               :datetime
#  interview_time_begin         :datetime
#  interview_time_end           :datetime
#  operator_at                  :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  performance_moderator_id     :integer
#  operator_id                  :integer
#  performance_interview_status :string
#
# Indexes
#
#  index_performance_interviews_on_appraisal_id               (appraisal_id)
#  index_performance_interviews_on_appraisal_participator_id  (appraisal_participator_id)
#  index_performance_interviews_on_operator_id                (operator_id)
#  index_performance_interviews_on_performance_moderator_id   (performance_moderator_id)
#
# Foreign Keys
#
#  fk_rails_16d742586a  (operator_id => users.id)
#  fk_rails_45608f34c2  (performance_moderator_id => users.id)
#  fk_rails_5df603477c  (appraisal_id => appraisals.id)
#  fk_rails_9d0ecbf1be  (appraisal_participator_id => appraisal_participators.id)
#

class PerformanceInterview < ApplicationRecord
  include StatementAble

  belongs_to :appraisal
  belongs_to :appraisal_participator
  has_many :attachment_items, as: :attachable
  belongs_to :performance_moderator, class_name: 'User', foreign_key: 'performance_moderator_id'
  belongs_to :operator, class_name: 'User', foreign_key: 'operator_id'


  def self.joined_query(param_id = nil)
    self.left_outer_joins(
        [
        ].concat(extra_joined_association_names)
    )
  end
  class << self
    def department_options
      Department.where(id: self.joins(:appraisal_participator => :user).select('users.department_id'))
    end

    def location_options
      Location.where(id: self.joins(:appraisal_participator => :user).select('users.location_id'))
    end

    def position_options
      Position.where(id: self.joins(:appraisal_participator => :user).select('users.position_id'))
    end

    def grade_options
      keys = self.joins(:appraisal_participator => :user).select('users.grade').map{|item| item['grade']}
      Config.get_option_from_selects('grade', keys)
    end

    def department_record_options
      Department.where(id: self.joins(:appraisal_employee_setting => :user).select('users.department_id'))
    end

    def location_record_options
      Location.where(id: self.joins(:appraisal_employee_setting  => :user).select('users.location_id'))
    end

    def position_record_options
      Position.where(id: self.joins(:appraisal_employee_setting  => :user).select('users.position_id'))
    end

    def grade_record_options
      keys = self.joins(:appraisal_participator => :user).select('users.grade').map{|item| item['grade']}
      Config.get_option_from_selects('grade', keys)
    end
  end
  scope :by_appraisal_name, -> (appraisal_name) {
    where(:appraisals => {appraisal_name: appraisal_name}) if appraisal_name
  }

  scope :by_appraisal_date, ->(appraisal_date) {
    from = Time.zone.parse(appraisal_date['begin']).beginning_of_day rescue nil
    to = Time.zone.parse(appraisal_date['end']).end_of_day rescue nil
    if from && to
      where('date_end >= :from AND date_begin <= :to', from: from, to: to)
    elsif from
      where('date_end >= :from', from: from)
    elsif to
      where('date_begin <= :to', to: to )
    end
  }

  scope :by_performance_interview_status, -> (performance_interview_status) {
    where(performance_interview_status: performance_interview_status) if performance_interview_status
  }

  scope :by_empoid, -> (empoid) {
    where(:users => { empoid: empoid }) if empoid
  }

  scope :by_name, -> (name) {
    where(:appraisal_participators => {user_id: User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: name).select(:id)}) if name
  }

  scope :by_location, -> (location) {
    where(:users => { location_id: location }) if location
  }

  scope :by_department, -> (department) {
    where(:users => { department_id: department }) if department
  }

  scope :by_position, -> (position) {
    where(:users => { position_id: position }) if position
  }

  scope :by_grade, -> (grade) {
    where(:users => { grade: grade }) if grade
  }

  scope :by_division_of_job, ->(division_of_job) {
    if division_of_job && (division_of_job.is_a? Array)
      where("profiles.data -> 'position_information' -> 'field_values' -> 'division_of_job' ?| array["+ division_of_job.map {|item| "'#{item}'"}.join(',') +"]")
    elsif division_of_job
      where("profiles.data #>> '{position_information, field_values, division_of_job}' = :division_of_job", division_of_job: division_of_job)
    end
  }

  scope :by_date_of_employment, ->(date_of_employment) {
    from = Time.zone.parse(date_of_employment[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_of_employment[:end]).end_of_day rescue nil
    if from && to
      includes({:appraisal_participator => {:user => :profile} })
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes({:appraisal_participator => {:user => :profile} }).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes({:appraisal_participator => {:user => :profile} }).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_interview_date, -> (interview_date) {
    from = Time.zone.parse(interview_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(interview_date[:end]).end_of_day rescue nil
    if from && to
      where("interview_date >= :from", from: from).where("interview_date <= :to", to: to)
    elsif from
      where("interview_date >= :from", from: from)
    elsif to
      where("interview_date <= :to", to: to)
    end
  }

  scope :by_performance_moderator, -> (name) {
    where(performance_moderator_id: User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: name).select(:id)) if name
  }

  scope :by_operator, -> (name) {
    where(operator_id: User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: name).select(:id)) if name
  }

  scope :by_operator_at, -> (operator_at) {
    from = Time.zone.parse(operator_at[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(operator_at[:end]).end_of_day rescue nil
    if from && to
      where("operator_at >= :from", from: from).where("operator_at <= :to", to: to)
    elsif from
      where("operator_at >= :from", from: from)
    elsif to
      where("operator_at <= :to", to: to)
    end
  }

  #

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :appraisal_name        then order("appraisals.appraisal_name #{sort_direction}")
      when :appraisal_date        then order("appraisals.date_begin #{sort_direction}")
      when :empoid                then order("users.empoid #{sort_direction}")
      when :name                  then order("users.chinese_name #{sort_direction}")
      when :location              then order("users.location_id #{sort_direction}")
      when :department            then order("users.department_id #{sort_direction}")
      when :position              then order("users.position_id #{sort_direction}")
      when :grade                 then order("users.grade #{sort_direction}")
      when :division_of_job       then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, division_of_job}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, division_of_job}' ")
        end
      when :date_of_employment    then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
        end
      when :performance_moderator then order("performance_moderators_performance_interviews #{sort_direction}")
      when :operator              then order("operators_performance_interviews #{sort_direction}")
      else
        order(sort_column => sort_direction)
    end
  }

end
