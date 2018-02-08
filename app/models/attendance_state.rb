# == Schema Information
#
# Table name: attendance_states
#
#  id           :integer          not null, primary key
#  code         :string
#  chinese_name :string
#  english_name :string
#  comment      :text
#  parent_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_attendance_states_on_code       (code)
#  index_attendance_states_on_parent_id  (parent_id)
#

class AttendanceState < ApplicationRecord
  belongs_to :parent, class_name: 'AttendanceState', foreign_key: :parent_id
  has_many :children, class_name: 'AttendanceState', foreign_key: :parent_id
  validates :code , uniqueness: true
end
