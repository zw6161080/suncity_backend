# == Schema Information
#
# Table name: class_settings
#
#  id                   :integer          not null, primary key
#  region               :string
#  department_id        :integer
#  name                 :string
#  display_name         :string
#  start_time           :datetime
#  end_time             :datetime
#  late_be_allowed      :integer
#  leave_be_allowed     :integer
#  overtime_before_work :integer
#  overtime_after_work  :integer
#  be_used              :boolean
#  be_used_count        :integer          default(0)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  is_next_of_start     :boolean
#  is_next_of_end       :boolean
#  new_code             :string
#  code                 :string
#
# Indexes
#
#  index_class_settings_on_department_id  (department_id)
#

class ClassSetting < ApplicationRecord
  belongs_to :department

  def self.set_be_used
    ClassSetting.all.each do |c|
      be_used_at_roster_object = RosterObject.where(class_setting_id: c.id).count > 0

      be_used_at_roster_model = RosterModelWeek
                                  .where("mon_class_setting_id = ? OR tue_class_setting_id = ? OR wed_class_setting_id = ? OR thu_class_setting_id = ? OR fri_class_setting_id = ? OR sat_class_setting_id = ? OR sun_class_setting_id = ?", c.id, c.id, c.id, c.id, c.id, c.id, c.id)
                                  .count > 0

      c.be_used = be_used_at_roster_object || be_used_at_roster_model
      c.save!
    end
  end

  def fmt_code
    if self.code.to_i != 0
      self.code.to_s.rjust(3, '0')
    end
  end
end
