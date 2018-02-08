# == Schema Information
#
# Table name: training_courses
#
#  id                                     :integer          not null, primary key
#  region                                 :string
#  user_id                                :integer
#  transfer_position_apply_by_employee_id :integer
#  chinese_name                           :string
#  english_name                           :string
#  simple_chinese_name                    :string
#  explanation                            :string
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#
# Indexes
#
#  index_training_courses_on_user_id          (user_id)
#  transfer_position_apply_by_employee_index  (transfer_position_apply_by_employee_id)
#

class TrainingCourse < ApplicationRecord
  belongs_to :user
  belongs_to :transfer_position_apply_by_employee
end
