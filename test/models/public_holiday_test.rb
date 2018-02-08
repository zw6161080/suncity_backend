# == Schema Information
#
# Table name: public_holidays
#
#  id           :integer          not null, primary key
#  chinese_name :string
#  english_name :string
#  category     :integer
#  start_date   :date
#  end_date     :date
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class PublicHolidayTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
