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

require 'test_helper'

class AssistantProfileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
