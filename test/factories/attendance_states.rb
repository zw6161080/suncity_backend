# == Schema Information
#
# Table name: attendance_states
#
#  id           :integer          not null, primary key
#  code         :string
#  chinese_name :string
#  english_name :string
#  comment      :text
#  parent_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :attendance_state do
    code '001'
    chinese_name '上班忘打卡'
    english_name 'Forgot clock in'
  end
end
