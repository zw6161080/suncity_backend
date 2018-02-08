# == Schema Information
#
# Table name: roster_preferences
#
#  id                :integer          not null, primary key
#  roster_list_id    :integer
#  location_id       :integer
#  department_id     :integer
#  latest_updater_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_roster_preferences_on_department_id      (department_id)
#  index_roster_preferences_on_latest_updater_id  (latest_updater_id)
#  index_roster_preferences_on_location_id        (location_id)
#

class RosterPreference < ApplicationRecord
  # belongs_to :roster_list
  belongs_to :latest_updater, :class_name => "User", :foreign_key => "latest_updater_id"
  belongs_to :location
  belongs_to :department
  has_many :class_people_preferences, -> { order "class_setting_id ASC" }
  has_many :roster_interval_preferences
  has_many :general_holiday_interval_preferences
  has_many :classes_between_general_holiday_preferences
  has_many :whether_together_preferences

  has_many :employee_preferences

  def self.initial_table
    location_ids = Location.all.pluck(:id)
    location_ids.each do |l_id|
      loc = Location.find(l_id)
      loc.department_ids.each do |d_id|
        if RosterPreference.where(location_id: l_id, department_id: d_id, roster_list_id: nil).count == 0
          RosterPreference.initial_preference(User.first.id, l_id, d_id)
        end
      end
    end
  end

  def self.initial_preference(updater, location_id, department_id)
    # location_id, department_id = roster_list.location_id, roster_list.department_id
    p = RosterPreference.create(location_id: location_id,
                                department_id: department_id,
                                latest_updater_id: updater
                               )

    class_settings = ClassSetting.where(department_id: department_id)

    class_settings.each do |setting|
      p.class_people_preferences.create(class_setting_id: setting.id,
                                        max_of_total: 1000,
                                        min_of_total: 0,
                                        max_of_manager_level: 1000,
                                        min_of_manager_level: 0,
                                        max_of_director_level: 1000,
                                        min_of_director_level: 0)
    end

    # TODO: try as_json -> hash.merge
    p.class_people_preferences.create(class_setting_id: nil,
                                      max_of_total: 1000,
                                      min_of_total: 0,
                                      max_of_manager_level: 1000,
                                      min_of_manager_level: 0,
                                      max_of_director_level: 1000,
                                      min_of_director_level: 0
                                     )

    # location_position_ids = Location.where(id: location_id).first.position_ids
    # department_position_ids = Department.where(id: department_id).first.position_ids
    # position_ids = location_position_ids & department_position_ids

    # position_ids = User.where(location_id: location_id, department_id: department_id).pluck(:position_id).compact.uniq

    # positions = Position.where(id: position_ids)

    positions = Position.joins(:departments, :locations).where('departments.id = ? AND locations.id = ?', department_id, location_id)

    positions.each do |position|
      p.roster_interval_preferences.create(position_id: position.id, interval_hours: 0)
      p.general_holiday_interval_preferences.create(position_id: position.id)
      p.classes_between_general_holiday_preferences.create(position_id: position.id)
    end

    # employee preferences

    users = User.where(location_id: location_id, department_id: department_id)
    users.each do |u|
      p.employee_preferences.create(user_id: u.id)
    end
  end

  def self.add_new_class_people_preference(department_id, class_setting)
    roster_preferences = RosterPreference.where(department_id: department_id)
    roster_preferences.each do |p|
      p.class_people_preferences.create(class_setting_id: class_setting.id,
                                        max_of_total: 1000,
                                        min_of_total: 0,
                                        max_of_manager_level: 1000,
                                        min_of_manager_level: 0,
                                        max_of_director_level: 1000,
                                        min_of_director_level: 0)
    end
  end

  def self.remove_class_people_preference(department_id, class_setting)
    roster_preferences = RosterPreference.where(department_id: department_id)
    roster_preferences.each do |p|
      should_delete = p.class_people_preferences.where(class_setting_id: class_setting.id).first
      should_delete.destroy if should_delete
    end
  end

  def self.add_interval(department_id, position_id)
    roster_preferences = RosterPreference.where(department_id: department_id)
    roster_preferences.each do |p|
      p.roster_interval_preferences.create(position_id: position_id, interval_hours: 0)
      p.general_holiday_interval_preferences.create(position_id: position_id)
      p.classes_between_general_holiday_preferences.create(position_id: position_id)
    end
  end

  def self.remove_interval(department_id, position_id)
    roster_preferences = RosterPreference.where(department_id: department_id)
    roster_preferences.each do |p|
      del_1 = p.roster_interval_preferences.where(position_id: position_id).first
      del_1.destroy if del_1
      del_2 = p.general_holiday_interval_preferences.where(position_id: position_id).first
      del_2.destroy if del_2
      del_3 = p.classes_between_general_holiday_preferences.where(position_id: position_id).first
      del_3.destroy if del_3
    end
  end

  def remove_dup_general_holiday_settings
    general_holiday_settings = self.class_people_preferences.where(class_setting_id: nil)
    first_genneral_holiday_setting = general_holiday_settings.order(created_at: :asc).first
    if first_genneral_holiday_setting
      general_holiday_settings.each do |setting|
        if setting.id != first_genneral_holiday_setting.id
          setting.destroy
        end
      end
    end

    self.class_people_preferences.each do |p|
      if p.class_setting_id != nil
        detail = ClassSetting.find_by(id: p.class_setting_id)
        p.destroy if (detail == nil)
      end
    end
  end

  def setting_intervals
    positions = Position.joins(:departments, :locations).where('departments.id = ? AND locations.id = ?', self.department_id, self.location_id)

    positions.each do |position|
      if self.roster_interval_preferences.where(position_id: position.id).count == 0
        self.roster_interval_preferences.create(position_id: position.id, interval_hours: 0)
      end

      if self.general_holiday_interval_preferences.where(position_id: position.id).count == 0
        self.general_holiday_interval_preferences.create(position_id: position.id)
      end

      if self.classes_between_general_holiday_preferences.where(position_id: position.id).count == 0
        self.classes_between_general_holiday_preferences.create(position_id: position.id)
      end
    end
  end

  def setting_employee_preferences
    users = User.where(location_id: location_id, department_id: department_id)
    users.each do |u|
      if self.employee_preferences.where(user_id: u.id).count == 0
        self.employee_preferences.create(user_id: u.id)
      end
    end
  end
end
