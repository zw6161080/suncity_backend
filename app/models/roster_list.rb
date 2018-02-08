# == Schema Information
#
# Table name: roster_lists
#
#  id                     :integer          not null, primary key
#  region                 :string
#  status                 :integer
#  chinese_name           :string
#  english_name           :string
#  simple_chinese_name    :string
#  location_id            :integer
#  department_id          :integer
#  date_range             :string
#  start_date             :date
#  end_date               :date
#  employment_counts      :integer
#  roster_counts          :integer
#  general_holiday_counts :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  calc_state             :integer
#
# Indexes
#
#  index_roster_lists_on_department_id  (department_id)
#  index_roster_lists_on_location_id    (location_id)
#

class RosterList < ApplicationRecord
  belongs_to :location
  belongs_to :department

  # has_one :roster_preference
  has_many :roster_objects

  enum status: { is_draft: 0, is_public: 1, is_sealed: 2 }

  enum calc_state: { not_calc: 0, calculating: 1, calculated: 2 }

  scope :by_location_id, lambda { |location_id|
    where(location_id: location_id) if location_id
  }

  scope :by_department_id, lambda { |department_id|
    where(department_id: department_id) if department_id
  }

  scope :by_name, lambda { |name, lang|
    where("#{lang} like ?", "%#{name}%") if name
  }

  scope :by_date, lambda { |date|
    where(start_date: date) if date
  }

  scope :by_date_range, lambda { |start_d, end_d|
    if start_d && end_d
      where("start_date >= ? AND start_date <= ?", start_d, end_d)
    elsif start_d && !end_d
      where("start_date >= ?", start_d)
    elsif !start_d && end_d
      where("start_date <= ?", end_d)
    end
  }

  scope :by_status, lambda { |status|
    where(status: status) if status
  }

  scope :by_roster_list_ids, lambda { |roster_list_ids|
    where(id: roster_list_ids) if roster_list_ids
  }

  def realtime_employment_counts
    # counts = User.where(location_id: self.location_id, department_id: self.department_id).count
    ros = RosterObject.where(location_id: self.location_id, department_id: self.department_id)
            .where(roster_date: self.start_date .. self.end_date)
    counts = ros.pluck(:user_id).uniq.size rescue 0
    self.employment_counts = counts
    self.save!
    counts
  end

  def roster_preferences_id
    pp = RosterPreference.where(location_id: self.location_id,
                                department_id: self.department_id).first
    pp ? pp.id : nil
  end

  def fill_in_data
    ros = RosterObject.where(location_id: self.location_id, department_id: self.department_id)
            .where(roster_date: self.start_date .. self.end_date)

    # rosters = ros.where(holiday_type: nil, borrow_return_type: nil, adjust_type: nil)
    tmp_rosters = ros.where(holiday_type: nil)

    true_ro_ids = []
    tmp_rosters.each do |t_ro|
      # u = User.find_by(id: t_ro.user_id)
      d = t_ro.roster_date
      date_of_employment = t_ro.user.profile.data['position_information']['field_values']['date_of_employment']
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

      position_resigned_date = t_ro.user.profile.data['position_information']['field_values']['resigned_date']
      leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

      is_entry = (entry && (d >= entry))
      not_leave = (leave == nil || (d <= leave))
      true_ro_ids << t_ro.id if (is_entry && not_leave)
    end

    rosters = RosterObject.where(id: true_ro_ids.compact.uniq)

    class_setting_roster = rosters.where(is_general_holiday: [false, nil], working_time: nil).where.not(class_setting_id: nil).count
    working_time_roster = rosters.where(is_general_holiday: [false, nil], class_setting_id: nil).where.not(working_time: nil).count

    self.roster_counts = class_setting_roster + working_time_roster

    self.general_holiday_counts = rosters.where(is_general_holiday: true).count


    counts = ros.pluck(:user_id).uniq.size rescue 0

    self.employment_counts = counts
    self.save!
  end

  def roster_list_users
    user_ids = []
    all_users = User.all
    start_date = self.start_date.to_date
    end_date = self.end_date.to_date
    location_id = self.location_id
    department_id = self.department_id
    (start_date .. end_date).each do |d|
      all_users.each do |u|
        if location_id == ProfileService.location(u, d.to_datetime)&.id &&
           department_id == ProfileService.department(u, d.to_datetime)&.id
          user_ids << u.id
        end
      end
    end

    uniq_user_ids = user_ids.compact.uniq
    users = User.where(id: uniq_user_ids)
    users
  end

  def self.find_list(date, location_id, department_id)
    RosterList.where(location_id: location_id, department_id: department_id)
      .where("start_date <= ? AND end_date >= ?", date, date).first
  end
end
