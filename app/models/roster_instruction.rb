# == Schema Information
#
# Table name: roster_instructions
#
#  id         :integer          not null, primary key
#  comment    :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_roster_instructions_on_user_id  (user_id)
#

class RosterInstruction < ApplicationRecord
  belongs_to :user
end
