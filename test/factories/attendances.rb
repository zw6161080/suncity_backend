# == Schema Information
#
# Table name: attendances
#
#  id                       :integer          not null, primary key
#  department_id            :integer
#  location_id              :integer
#  year                     :string
#  month                    :string
#  region                   :string
#  snapshot_employees_count :integer
#  rosters                  :integer
#  public_holidays          :integer
#  attendance_record        :integer
#  unusual_attendances      :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roster_id                :integer
#

FactoryGirl.define do
  factory :attendance do
    year Time.now.year
    month Time.now.month
    region 'macau'
    location
    department
  end
end
