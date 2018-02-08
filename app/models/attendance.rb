# coding: utf-8
# == Schema Information
#
# Table name: attendances
#
#  id                       :integer          not null, primary key
#  department_id            :integer
#  location_id              :integer
#  year                     :string
#  month                    :string
#  region                   :string
#  snapshot_employees_count :integer
#  rosters                  :integer
#  public_holidays          :integer
#  attendance_record        :integer
#  unusual_attendances      :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roster_id                :integer
#
# Indexes
#
#  all                                                    (year,month,department_id,location_id) UNIQUE
#  index_attendances_on_department_id                     (department_id)
#  index_attendances_on_location_id                       (location_id)
#  index_attendances_on_region                            (region)
#  index_attendances_on_roster_id                         (roster_id)
#  index_attendances_on_year_and_month                    (year,month)
#  index_attendances_on_year_and_month_and_department_id  (year,month,department_id)
#  index_attendances_on_year_and_month_and_location_id    (year,month,location_id)
#
# Foreign Keys
#
#  fk_rails_2d53585e56  (roster_id => rosters.id)
#

class Attendance < ApplicationRecord
  belongs_to :location
  belongs_to :department
  has_many :items, class_name: 'AttendanceItem'

  before_create :fill_snapshot_employees_count

  scope :by_month, lambda { |month|
    where(:month => month) if month
  }

  scope :by_year, lambda { |year|
    where(:year => year) if year
  }

  scope :by_location_id, lambda { |location_id|
    where(:location_id => location_id) if location_id
  }

  scope :by_department_id, lambda { |department_id|
    where(:department_id => department_id) if department_id
  }

  scope :by_region, lambda { |region|
    where(:region => region) if region
  }

  def department_employees_count
    # department.employees_count
    User.where(location_id: self.location.id, department_id: self.department.id).count
  end

  def fill_snapshot_employees_count
    self.snapshot_employees_count = User.where(location_id: self.location.id, department_id: self.department.id).count
  end

  def find_roster_items
    start_date = Time.zone.local(self.year.to_i, self.month.to_i, 1).to_datetime
    end_date = start_date.end_of_month

    roster_ids = Roster.includes([:department, :location])
                   .where(region: self.region,
                          location_id: self.location_id,
                          department_id: self.department_id)
                   .pluck(:id)

    RosterItem.where(date: start_date .. end_date,
                     roster_id: roster_ids)

    # middle_query = Roster.includes([:department, :location])
    #                  .where(region: self.region,
    #                         location_id: self.location_id,
    #                         department_id: self.department_id)

    # inside = middle_query.inside_from_to(start_date, end_date).pluck(:id)
    # left = middle_query.left_side_from_to(start_date, end_date).pluck(:id)
    # right = middle_query.right_side_from_to(start_date, end_date).pluck(:id)
    # outside = middle_query.outside_from_to(start_date, end_date).pluck(:id)

    # RosterItem.where(date: start_date .. end_date,
    #                  roster_id: inside + left + right + outside)


    # RosterItem 沒有region，location_id，department_id

    # RosterItem.where(date: start_date .. end_date,
    #                  region: self.region,
    #                  location_id: self.location_id,
    #                  department_id: self.department_id)
  end

  def office_leave_count
    items = find_roster_items
    fixed_count = items.where(state: :fixed).pluck(:date).select { |d| d.saturday? || d.sunday? }.count
    normal_count = items.where.not(state: :fixed).where(leave_type: 'offical_leave').count
    fixed_count + normal_count
  end

  def roster_items_count
    items = find_roster_items
    fixed_count = items.where(state: :fixed).count
    shift_count = items.where.not(state: :fixed).where("shift_id > ?", 0).count
    office_leave_count = items.where.not(state: :fixed).where(leave_type: 'offical_leave').count
    fixed_count + shift_count + office_leave_count
  end

  def find_attendance_items
    AttendanceItem.where(region: self['region'])
      .by_date(self['year'], self['month'])
      .by_location_id(self['location_id'])
      .by_department_id(self['department_id'])
  end

  def punching_card_records
    attendance_items = find_attendance_items
    on_records = attendance_items.where.not(start_working_time: nil).count
    off_records = attendance_items.where.not(end_working_time: nil).count
    on_records + off_records
  end

  def unusual_punching_card_records
    attendance_items = find_attendance_items
    stated_items = attendance_items.where.not(states: "")
    stated_items.pluck(:states).map do |states|
      format_states = states.gsub(/[@|]/, ',').split(', ').join(',').split(',')
      on_unusual = format_states.include?("上班打卡異常") ? 1 : 0
      off_unusual = format_states.include?("下班打卡異常") ? 1 : 0
      on_unusual + off_unusual
    end.reduce(& :+)
  end

  # def start_attendancing
  #   roster = Roster.find(self.roster_id)
  #   roster_items = roster.items

  #   roster_items.each do |item|
  #     user = User.find(item.user_id)
  #     attendance_item = AttendanceItem.new
  #     attendance_item.user = user
  #     attendance_item.position_id = user.position_id
  #     attendance_item.department_id = user.department_id
  #     attendance_item.attendance_id = self.id
  #     attendance_item.shift_id = item.shift_id
  #     attendance_item.save!
  #   end
  # end

  def self.generate_attendance_list(year, month)
    locations = Location.all
    locations.each do |location|
      departments = Department.joins(:locations).where('locations.id = ?', location['id'])
      departments.each do |department|
        attendance = Attendance.new
        attendance.region = 'macau'
        attendance.year = year
        attendance.month = month
        attendance.location_id = location['id']
        attendance.department_id = department['id']
        attendance.save
      end
    end

    # rosters = Roster.where(year: year, month: month)
    # rosters.each do |roster|
    #   attendance = Attendance.new
    #   attendance.region = roster.region
    #   attendance.year = roster.year
    #   attendance.month = roster.month
    #   attendance.roster_id = roster.id
    #   attendance.department_id = roster.department_id
    #   # attendance.location_id = roster.location_id
    #   attendance.save
    # end
  end

end
