# == Schema Information
#
# Table name: agreement_files
#
#  id                    :integer          not null, primary key
#  agreement_id          :integer
#  applicant_position_id :integer
#  attachment_id         :integer
#  creator_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  file_key              :string
#

require 'test_helper'

class AgreementFileTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
