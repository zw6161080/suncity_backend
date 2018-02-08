# == Schema Information
#
# Table name: special_schedule_remarks
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  date_begin :datetime
#  date_end   :datetime
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_special_schedule_remarks_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_0107a3cc1e  (user_id => users.id)
#

class SpecialScheduleRemark < ApplicationRecord
  include StatementAble

  belongs_to :user

  def self.create_records(profile, records)
    records.each do |record|
      special_schedule_remark = self.new(record.permit(:content, :date_end, :date_begin).merge(user_id: profile.user_id))
      special_schedule_remark.save!
    end
  end

  def self.joined_query(param_id = nil)
    self.left_outer_joins(
        [
        ].concat(extra_joined_association_names)
    )
  end

  scope :by_user_ids, ->(user_ids) {
    where(:users => { id: user_ids})
  }

  scope :by_empoid, ->(empoid) {
    where(:users => { empoid: empoid})
  }

  scope :by_name, ->(name) {
    where('users.chinese_name = :name OR users.english_name = :name OR users.simple_chinese_name = :name', name: name)
  }

  scope :by_department, -> (department) {
    where(:users => { department_id: department })
  }

  scope :by_position, -> (position) {
    where(:users => { position_id: position })
  }

  scope :by_date_of_employment, ->(date_of_employment) {
    from = Time.zone.parse(date_of_employment[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_of_employment[:end]).end_of_day rescue nil
    if from && to
      includes(user: :profile)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_date_begin, -> (date_begin) {
    from = Time.zone.parse(date_begin[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_begin[:end]).end_of_day rescue nil
    if from && to
      where('date_begin >= :from AND date_begin <= :to', from: from, to: to)
    elsif from
      where('date_begin >= :from', from: from)
    elsif to
      where('date_begin <= :to', to: to)
    end
  }

  scope :by_date_end, -> (date_end) {
    from = Time.zone.parse(date_end[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_end[:end]).end_of_day rescue nil
    if from && to
      where('date_begin >= :from AND date_begin <= :to', from: from, to: to)
    elsif from
      where('date_end >= :from', from: from)
    elsif to
      where('date_end <= :to', to: to)
    end
  }

  scope :by_query_date, -> (query_date) {
    from = Time.zone.parse(query_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(query_date[:end]).end_of_day rescue nil
    if from && to
      where('date_begin <= :to AND date_begin >= :from', from: from, to: to)
    elsif from
      where('date_end >= :from', from: from)
    elsif to
      where('date_begin <= :to', to: to)
    end
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid              then order("users.empoid #{sort_direction}")
      when :name                then order("users.chinese_name #{sort_direction}")
      when :department          then order("users.department_id #{sort_direction}")
      when :position            then order("users.position_id #{sort_direction}")
      when :date_of_employment  then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
        end
      when :date_begin          then order("date_begin #{sort_direction}")
      when :date_end            then order("date_end #{sort_direction}")
      else
        order(sort_column => sort_direction)
    end
  }

end
