class AnnualBonusItemSerializer < ActiveModel::Serializer
  attributes :id,
             :has_annual_incentive_payment,
             :annual_incentive_payment_hkd,
             :has_double_pay,
             :double_pay_mop,
             :has_year_end_bonus,
             :year_end_bonus_mop
  has_one :user
end
