# == Schema Information
#
# Table name: contract_information_types
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  description         :text
#  type                :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  simple_chinese_name :string
#

class ContractInformationType < ApplicationRecord
  has_many :contract_informations

  def destroy
    unless can_delete?
      raise LogicError, { message: "Cannot delete contract informations with attachments" }.to_json
    end

    super
  end

  def simple_chinese_name
    chinese_name
  end

  def can_delete?
    contract_informations.count == 0
  end

  def total_count
    contract_informations.count
  end
end
