# == Schema Information
#
# Table name: employee_preferences
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  roster_preference_id :integer
#
# Indexes
#
#  index_employee_preferences_on_roster_preference_id  (roster_preference_id)
#  index_employee_preferences_on_user_id               (user_id)
#

class EmployeePreference < ApplicationRecord
  belongs_to :user
  belongs_to :roster_preference
  has_many :employee_roster_preferences, dependent: :destroy
  has_many :employee_general_holiday_preferences, dependent: :destroy

  scope :by_empoid, lambda { |empoid|
    if empoid
      user_ids = User.where("empoid like ?", "%#{empoid}%")
      where(user_id: user_ids)
    end
  }

  scope :by_user_name, lambda { |name|
    if name
      user_ids = User.where("#{select_language.to_s} like ?", "%#{name}%")
      where(user_id: user_ids)
    end
  }

  scope :by_department, lambda { |department_id|
    if department_id
      user_ids = User.where(department_id: department_id)
      where(user_id: user_ids)
    end
  }

  scope :by_position, lambda { |position_id|
    if position_id
      user_ids = User.where(position_id: position_id)
      where(user_id: user_ids)
    end
  }

  scope :by_date_of_employment, lambda { |date_of_employment|
    if date_of_employment
      query = self
      range = date_of_employment[:begin].in_time_zone.to_date .. date_of_employment[:end].in_time_zone.to_date
      ids = []
      query.all.each do |record|
        if range.include?(User.find(record['user_id']).career_records.order(career_begin: :asc).first&.career_begin)
          ids += [record.id]
        end
      end
      query = query.where(id: ids)
      query
    end
  }

  def self.setting_users(roster_preference)
    users = User.where(location_id: roster_preference.location_id, department_id: roster_preference.department_id)

    u_ids = users.pluck(:id)
    roster_preference.employee_preferences.each do |ep|
      if u_ids.select { |id| id == ep.user_id }.count <= 0
        ep.destroy
      end
    end

    users.each do |u|
      if roster_preference.employee_preferences.where(user_id: u.id).count == 0
        roster_preference.employee_preferences.create(user_id: u.id)
      end
    end
  end
end
