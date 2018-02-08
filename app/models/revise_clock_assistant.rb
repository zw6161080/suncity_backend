# == Schema Information
#
# Table name: revise_clock_assistants
#
#  id                   :integer          not null, primary key
#  revise_clock_item_id :integer
#  sign_time            :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_revise_clock_assistants_on_revise_clock_item_id  (revise_clock_item_id)
#

class ReviseClockAssistant < ApplicationRecord
  belongs_to :revise_clock_item
end
