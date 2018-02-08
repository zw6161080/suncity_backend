# == Schema Information
#
# Table name: paid_sick_leave_awards
#
#  id                 :integer          not null, primary key
#  award_chinese_name :string           not null
#  award_english_name :string           not null
#  begin_date         :string           not null
#  due_date           :string           not null
#  has_offered        :integer          default("false"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class PaidSickLeaveAwardTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
