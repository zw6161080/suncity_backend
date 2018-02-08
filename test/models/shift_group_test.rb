# == Schema Information
#
# Table name: shift_groups
#
#  id              :integer          not null, primary key
#  chinese_name    :string
#  english_name    :string
#  comment         :text
#  member_user_ids :jsonb
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  roster_id       :integer
#  is_together     :boolean          default(TRUE)
#

require 'test_helper'

class ShiftGroupTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
