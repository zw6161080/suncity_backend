# == Schema Information
#
# Table name: assistant_profile_to_annual_work_awards
#
#  id                   :integer          not null, primary key
#  profile_id           :integer
#  annual_work_award_id :integer
#  date_of_employment   :string
#  up_to_standard       :integer
#  money_of_award       :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class AssistantProfileToAnnualWorkAwardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
