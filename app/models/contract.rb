# == Schema Information
#
# Table name: contracts
#
#  id                    :integer          not null, primary key
#  applicant_position_id :integer
#  time                  :string
#  comment               :text
#  status                :integer
#  cancel_reason         :text
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_contracts_on_applicant_position_id  (applicant_position_id)
#

class Contract < ApplicationRecord
  belongs_to :applicant_position
  enum status: { modified: 1, cancelled: 2 }
  
end
