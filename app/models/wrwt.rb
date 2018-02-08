# == Schema Information
#
# Table name: wrwts
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  provide_airfare       :boolean
#  provide_accommodation :boolean
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  airfare_type          :string
#  airfare_count         :integer
#

class Wrwt < ApplicationRecord
  include WrwtValidators
  validates :provide_accommodation, inclusion: {in: [false, true]}
  validates :airfare_type, inclusion: { in: %w(round one_way count)}, if: :can_provide_airfare?
  validates :airfare_count, presence: true, if: :calculate_in_count?
  validates_with UserWithoutWrwtValidator, on: :create
  def can_provide_airfare?
    self.provide_airfare
  end

  def calculate_in_count?
    self.airfare_type == 'count'
  end

  def self.wrwt_information_options
    {
      provide_airfare: Config.get_all_option_from_selects(:provide_airfare),
      provide_accommodation: Config.get_all_option_from_selects(:provide_accommodation)
    }
  end
end
