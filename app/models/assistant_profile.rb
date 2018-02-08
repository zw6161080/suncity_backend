# == Schema Information
#
# Table name: assistant_profiles
#
#  id                       :integer          not null, primary key
#  profile_id               :integer
#  paid_sick_leave_award_id :integer
#  date_of_employment       :string
#  days_in_office           :integer
#  has_used_days            :integer
#  days_of_award            :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#
# Indexes
#
#  index_assistant_profiles_on_paid_sick_leave_award_id  (paid_sick_leave_award_id)
#

class AssistantProfile < ApplicationRecord
  belongs_to :paid_sick_leave_award
end
