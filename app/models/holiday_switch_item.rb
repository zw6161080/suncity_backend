# == Schema Information
#
# Table name: holiday_switch_items
#
#  id                :integer          not null, primary key
#  holiday_switch_id :integer
#  type              :integer
#  user_id           :integer
#  user_b_id         :integer
#  a_date            :date
#  b_date            :date
#  a_start           :string
#  a_end             :string
#  b_start           :string
#  b_end             :string
#  status            :integer          default("approved"), not null
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  a_type            :string
#  b_type            :string
#
# Indexes
#
#  index_holiday_switch_items_on_holiday_switch_id  (holiday_switch_id)
#  index_holiday_switch_items_on_user_b_id          (user_b_id)
#  index_holiday_switch_items_on_user_id            (user_id)
#
# Foreign Keys
#
#  fk_rails_6dfc01c449  (holiday_switch_id => holiday_switches.id)
#

class HolidaySwitchItem < ApplicationRecord
  belongs_to :holiday_switch
  belongs_to :user
  belongs_to :user_b, :class_name => "User", :foreign_key => "user_b_id"
  before_save :set_time
  enum type: { work_switch: 0,
               rest_switch: 1 }

  enum status: {approved: 1}

  def set_time
    user= self.holiday_switch.user
    user_b = self.holiday_switch.user_b
    self.user_id = user.id if user
    self.user_b_id = user_b.id if user_b
    shift_a = RosterItem.by_user(user.id).by_date(a_date).first.try(:shift)  if user
    shift_b = RosterItem.by_user(user_b.id).by_date(b_date).first.try(:shift) if user_b
    self.a_start = shift_a.start_time_at if shift_a
    self.a_end = shift_a.end_time_at if shift_a
    self.b_start = shift_b.start_time_at if shift_b
    self.b_end = shift_b.end_time_at if shift_b
  end

end
