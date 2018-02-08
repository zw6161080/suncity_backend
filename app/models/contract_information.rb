# == Schema Information
#
# Table name: contract_informations
#
#  id                           :integer          not null, primary key
#  profile_id                   :integer
#  contract_information_type_id :integer
#  attachment_id                :integer
#  description                  :text
#  creator_id                   :integer
#  file_name                    :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_contract_informations_on_attachment_id                 (attachment_id)
#  index_contract_informations_on_contract_information_type_id  (contract_information_type_id)
#  index_contract_informations_on_creator_id                    (creator_id)
#  index_contract_informations_on_profile_id                    (profile_id)
#

class ContractInformation < ApplicationRecord
  belongs_to :profile
  belongs_to :contract_information_type, foreign_key: 'contract_information_type_id'
  belongs_to :attachment, dependent: :destroy
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"

  after_create :update_contract_filled_information_types
  before_destroy :update_contract_filled_information_types

  def destroy
    self.attachment&.destroy
    super
  end

  def add_row(params, current_user=nil)
    self.assign_attributes(params)
    self.creator = current_user
    self.save
  end

  def update_contract_filled_information_types
    profile.update_filled_attachment_types
  end

end
