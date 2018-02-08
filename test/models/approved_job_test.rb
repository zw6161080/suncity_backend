# == Schema Information
#
# Table name: approved_jobs
#
#  id                :integer          not null, primary key
#  approved_job_name :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  number            :integer
#

require 'test_helper'

class ApprovedJobTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
