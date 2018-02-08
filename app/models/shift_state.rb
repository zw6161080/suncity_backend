# == Schema Information
#
# Table name: shift_states
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_is_shift      :boolean          default(TRUE)
#  current_working_hour  :string
#  future_is_shift       :boolean
#  future_working_hour   :string
#  future_affective_date :datetime
#
# Indexes
#
#  index_shift_states_on_user_id  (user_id)
#

class ShiftState < ApplicationRecord
  belongs_to :user

  scope :by_today, lambda { |today|
    where("future_affective_date <= ?", today) if today
  }

  after_save :update_roster_items

  def self.auto_update
    ShiftState.by_today(Time.zone.now.to_date).each do |shift_state|
      shift_state['current_is_shift'] = shift_state['future_is_shift']
      shift_state['current_working_hour'] = shift_state['future_working_hour']

      shift_state['future_is_shift'] = nil
      shift_state['future_working_hour'] = nil
      shift_state['future_affective_date'] = nil

      shift_state.save
    end
  end

  def update_roster_items
    rosters = Roster.where(location_id: self.user.location_id, department_id: self.user.department_id)
    rosters.each { |roster| roster.generate_fixed_items(User.find(self.user_id)) }
  end

  def self.parse_time_string(time_str)
    from_time, to_time = time_str.to_s.split('-')
    { start_time: from_time, end_time: to_time }
  end

end
