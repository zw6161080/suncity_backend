# == Schema Information
#
# Table name: bonus_element_item_values
#
#  id                    :integer          not null, primary key
#  bonus_element_item_id :integer
#  bonus_element_id      :integer
#  value_type            :string
#  shares                :decimal(10, 2)
#  amount                :decimal(10, 2)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  subtype               :string
#  basic_salary          :decimal(10, 2)
#  per_share             :decimal(15, 4)
#
# Indexes
#
#  index_bonus_element_item_values_on_bonus_element_id       (bonus_element_id)
#  index_bonus_element_item_values_on_bonus_element_item_id  (bonus_element_item_id)
#
# Foreign Keys
#
#  fk_rails_8097d2d25f  (bonus_element_item_id => bonus_element_items.id)
#  fk_rails_ab7aa1255a  (bonus_element_id => bonus_elements.id)
#

class BonusElementItemValue < ApplicationRecord
  belongs_to :bonus_element_item
  belongs_to :bonus_element

  enum subtype: { business_development: 'business_development', operation: 'operation' }
  enum value_type: { personal: 'personal', departmental: 'departmental' }

  #贵宾卡消费转化为hkd
  def calc_amount
    if self.value_type == 'departmental'
      if self.bonus_element.key == 'vip_card_bonus'
        SalaryCalculatorService.mop_to_hkd(self.shares * self.per_share)
      else
        self.shares * self.per_share
      end
    else
      if self.bonus_element.key == 'vip_card_bonus'
        SalaryCalculatorService.mop_to_hkd(self.shares * self.per_share)
      else
        self.amount
      end
    end
  end

  def get_amount
    # if self.value_type == 'departmental'
    #   self.shares * self.per_share rescue BigDecimal(0)
    # else
    result = format('%.0f', self.amount) rescue nil
    result
    # end
  end
end
