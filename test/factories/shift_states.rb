# == Schema Information
#
# Table name: shift_states
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  current_is_shift      :boolean          default(TRUE)
#  current_working_hour  :string
#  future_is_shift       :boolean
#  future_working_hour   :string
#  future_affective_date :datetime
#

FactoryGirl.define do
  factory :shift_state do
    user

    current_is_shift {
      [true, false].sample
    }

    current_working_hour {
      %w(0900-1800 1200-2000).sample
    }

    future_is_shift nil
    future_working_hour nil
    future_affective_date nil


    trait :future do
      future_is_shift {
        [true, false].sample
      }

      future_working_hour {
        %w(1000-1900 1300-2100).sample
      }

      future_affective_date {
        %w(20170501 20170801).sample
      }
    end

    trait :affective_date_at_today do
      future_is_shift {
        [true, false].sample
      }

      future_working_hour {
        %w(1000-1900 1300-2100).sample
      }

      future_affective_date {
        Time.now.to_date
      }
    end

    trait :affective_date_before_today do
      future_is_shift {
        [true, false].sample
      }

      future_working_hour {
        %w(1000-1900 1300-2100).sample
      }

      future_affective_date {
        Time.now.yesterday.to_date
      }
    end
  end
end
