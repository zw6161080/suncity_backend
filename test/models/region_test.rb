# == Schema Information
#
# Table name: regions
#
#  key          :string           not null, primary key
#  chinese_name :string
#  english_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class RegionTest < ActiveSupport::TestCase
  test "region create" do
    assert 2, Region.count
  end
end
