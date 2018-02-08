# == Schema Information
#
# Table name: attend_approvals
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  date            :date
#  comment         :text
#  approvable_id   :integer
#  approvable_type :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_attend_approvals_on_approvable_type_and_approvable_id  (approvable_type,approvable_id)
#  index_attend_approvals_on_user_id                            (user_id)
#

class AttendApproval < ApplicationRecord
  belongs_to :approvable, polymorphic: true
  belongs_to :user
end
