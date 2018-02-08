# == Schema Information
#
# Table name: shift_groups
#
#  id              :integer          not null, primary key
#  chinese_name    :string
#  english_name    :string
#  comment         :text
#  member_user_ids :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  roster_id       :integer
#  is_together     :boolean          default(TRUE)
#
# Indexes
#
#  index_shift_groups_on_roster_id  (roster_id)
#

class ShiftGroup < ApplicationRecord
  belongs_to :roster

  def member_users
    self.member_user_ids ? User.select('id', 'chinese_name', 'english_name', 'empoid', 'email').where(id: member_user_ids) : []
  end
  
  def add_member_users(new_member_user_ids)
    self.member_user_ids = (Array(self.member_user_ids) + Array(new_member_user_ids)).uniq
    self.save
  end

  def remove_member_users(new_member_user_ids)
    self.member_user_ids = (Array(self.member_user_ids) - Array(new_member_user_ids)).uniq
    self.save
  end

end
