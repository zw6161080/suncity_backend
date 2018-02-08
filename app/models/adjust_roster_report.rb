# == Schema Information
#
# Table name: adjust_roster_reports
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  not_special             :integer
#  not_special_for_class   :integer
#  not_special_for_holiday :integer
#  special                 :integer
#  special_for_class       :integer
#  special_for_holiday     :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
# Indexes
#
#  index_adjust_roster_reports_on_user_id  (user_id)
#

class AdjustRosterReport < ApplicationRecord
  belongs_to :user
end
