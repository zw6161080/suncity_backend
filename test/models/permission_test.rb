# == Schema Information
#
# Table name: permissions
#
#  id         :integer          not null, primary key
#  resource   :string
#  action     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  region     :string
#

require 'test_helper'

class PermissionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
