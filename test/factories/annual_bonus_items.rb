FactoryGirl.define do
  factory :annual_bonus_item do
    user nil
    annual_bonus_event nil
    has_annual_incentive_payment false
    annual_incentive_payment_hkd "9.99"
    has_double_pay false
    double_pay_mop "9.99"
    has_year_end_bonus false
    year_end_bonus_mop "9.99"
  end
end
