# == Schema Information
#
# Table name: shifts
#
#  id                       :integer          not null, primary key
#  chinese_name             :string
#  start_time               :string
#  end_time                 :string
#  time_length              :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roster_id                :integer
#  english_name             :string
#  allow_be_late_minute     :integer
#  allow_leave_early_minute :integer
#  is_next                  :boolean
#

FactoryGirl.define do
  factory :shift do
    chinese_name {
      %w(早班 中班 晚班).sample
    }

    english_name {
      %w(am pm).sample
    }

    start_time '08:00'
    end_time '18:00'
  end
end
