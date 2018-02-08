# == Schema Information
#
# Table name: immediate_leave_items
#
#  id                 :integer          not null, primary key
#  immediate_leave_id :integer
#  comment            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  date               :date
#  shift_info         :string
#  work_time          :string
#  come               :string
#  leave              :string
#
# Indexes
#
#  index_immediate_leave_items_on_immediate_leave_id  (immediate_leave_id)
#

class ImmediateLeaveItem < ApplicationRecord
  belongs_to :immediate_leave
end
