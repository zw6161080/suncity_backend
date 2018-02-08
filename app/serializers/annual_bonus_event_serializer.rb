class AnnualBonusEventSerializer < ActiveModel::Serializer
  attributes :id,
             :chinese_name,
             :english_name,
             :simple_chinese_name,
             :begin_date,
             :end_date,
             :annual_incentive_payment_hkd,
             :year_end_bonus_rule,
             :year_end_bonus_mop,
             :settlement_type,
             :settlement_salary_year_month,
             :settlement_date,
             :grant_status
end
