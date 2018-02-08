# == Schema Information
#
# Table name: dimission_follow_ups
#
#  id            :integer          not null, primary key
#  dimission_id  :integer
#  event_key     :string
#  return_number :integer
#  is_confirmed  :boolean
#  handler_id    :integer
#  is_checked    :boolean
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  compensation  :decimal(10, 2)
#
# Indexes
#
#  index_dimission_follow_ups_on_dimission_id  (dimission_id)
#  index_dimission_follow_ups_on_handler_id    (handler_id)
#
# Foreign Keys
#
#  fk_rails_0609e2ae36  (dimission_id => dimissions.id)
#

class DimissionFollowUp < ApplicationRecord
  belongs_to :handler, :class_name => 'User', :foreign_key => 'handler_id'
  belongs_to :dimission

  def self.update_params
    self.columns.map(&:name) - %w(id dimission_id event_key handler_id created_at updated_at)
  end
end
