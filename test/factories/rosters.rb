# == Schema Information
#
# Table name: rosters
#
#  id                                    :integer          not null, primary key
#  department_id                         :integer
#  state                                 :string
#  region                                :string
#  shift_interval                        :jsonb
#  rest_day_amount_per_week              :jsonb
#  rest_day_interval                     :jsonb
#  in_between_rest_day_shift_type_amount :jsonb
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  snapshot_employees_count              :integer
#  location_id                           :integer
#  from                                  :date
#  to                                    :date
#  condition                             :jsonb
#

FactoryGirl.define do
  factory :roster do
    region 'macau'
    location
    department
    from Date.today.beginning_of_week
    to Date.today.end_of_week
    # from Time.now.beginning_of_month.beginning_of_week
    # to Time.now.end_of_month.end_of_week
  end
end
