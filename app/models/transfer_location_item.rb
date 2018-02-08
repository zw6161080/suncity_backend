# == Schema Information
#
# Table name: transfer_location_items
#
#  id                         :integer          not null, primary key
#  region                     :string
#  user_id                    :integer
#  transfer_location_apply_id :integer
#  transfer_date              :date
#  transfer_location_id       :integer
#  comment                    :text
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  salary_calculation         :string
#
# Indexes
#
#  index_transfer_location_items_on_transfer_location_apply_id  (transfer_location_apply_id)
#  index_transfer_location_items_on_transfer_location_id        (transfer_location_id)
#  index_transfer_location_items_on_user_id                     (user_id)
#

class TransferLocationItem < ApplicationRecord
  belongs_to :user
  belongs_to :transfer_location_apply
  belongs_to :transfer_location, class_name: 'Location', foreign_key: :transfer_location_id

end
