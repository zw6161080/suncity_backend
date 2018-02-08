# == Schema Information
#
# Table name: transfer_location_applies
#
#  id                 :integer          not null, primary key
#  region             :string
#  apply_date         :date
#  comment            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  salary_calculation :string
#

class TransferLocationApply < ApplicationRecord
  include JobTransferAble
  has_many :attend_attachments, as: :attachable, dependent: :destroy
  has_many :approval_items, as: :approvable, dependent: :destroy
  has_many :transfer_location_items
  has_many :job_transfers, as: :transferable
end
