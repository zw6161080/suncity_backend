# == Schema Information
#
# Table name: stored_settings
#
#  id         :integer          not null, primary key
#  var        :string           not null
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

require 'test_helper'

class StoredSettingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
