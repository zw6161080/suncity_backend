# == Schema Information
#
# Table name: beneficiaries
#
#  id               :integer          not null, primary key
#  name             :string
#  certificate_type :string
#  id_number        :string
#  relationship     :string
#  percentage       :decimal(15, 2)
#  address          :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Beneficiary < ApplicationRecord
end
