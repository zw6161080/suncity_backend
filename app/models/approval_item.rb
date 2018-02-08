# == Schema Information
#
# Table name: approval_items
#
#  id              :integer          not null, primary key
#  user_id         :integer
#  datetime        :datetime
#  comment         :text
#  approvable_type :string
#  approvable_id   :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_approval_items_on_approvable_type_and_approvable_id  (approvable_type,approvable_id)
#  index_approval_items_on_user_id                            (user_id)
#
# Foreign Keys
#
#  fk_rails_b9df624ca6  (user_id => users.id)
#

class ApprovalItem < ApplicationRecord
  belongs_to :user
  belongs_to :approvable, polymorphic: true
end
