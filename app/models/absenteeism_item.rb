# == Schema Information
#
# Table name: absenteeism_items
#
#  id             :integer          not null, primary key
#  absenteeism_id :integer
#  comment        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  date           :date
#  shift_info     :string
#  work_time      :string
#  come           :string
#  leave          :string
#
# Indexes
#
#  index_absenteeism_items_on_absenteeism_id  (absenteeism_id)
#

class AbsenteeismItem < ApplicationRecord
  belongs_to :absenteeism
end
