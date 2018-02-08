class CreatePayrollItems < ActiveRecord::Migration[5.0]
  def change
    create_table :payroll_items do |t|
      t.references :user, foreign_key: true
      t.datetime :year_month

      t.string :check_or_cash
      t.decimal :social_security_fund_reduction_mop, precision: 15, scale: 2
      t.decimal :actual_amount_mop, precision: 15, scale: 2
      t.decimal :actual_amount_hkd, precision: 15, scale: 2
      t.decimal :total_amount_mop, precision: 15, scale: 2
      t.decimal :base_salary_mop, precision: 15, scale: 2
      t.decimal :overtime_pay_mop, precision: 15, scale: 2
      t.decimal :compulsion_holiday_compensation_mop, precision: 15, scale: 2
      t.decimal :public_holiday_compensation_mop, precision: 15, scale: 2
      t.decimal :medicare_reimbursement_mop, precision: 15, scale: 2
      t.decimal :vip_card_consumption_mop, precision: 15, scale: 2
      t.decimal :paid_maternity_compensation_mop, precision: 15, scale: 2
      t.decimal :double_pay_mop, precision: 15, scale: 2
      t.decimal :year_end_bonus_mop, precision: 15, scale: 2
      t.decimal :seniority_compensation_mop, precision: 15, scale: 2
      t.decimal :dismission_annual_holiday_compensation_mop, precision: 15, scale: 2
      t.decimal :dismission_inform_period_compensation_mop, precision: 15, scale: 2
      t.decimal :total_reduction_mop, precision: 15, scale: 2
      t.decimal :medical_insurance_plan_reduction_mop, precision: 15, scale: 2
      t.decimal :public_accumulation_fund_reduction_mop, precision: 15, scale: 2
      t.decimal :love_fund_reduction_mop, precision: 15, scale: 2
      t.decimal :absenteeism_reduction_mop, precision: 15, scale: 2
      t.decimal :immediate_leave_reduction_mop, precision: 15, scale: 2
      t.decimal :unpaid_leave_reduction_mop, precision: 15, scale: 2
      t.decimal :unpaid_marriage_leave_reduction_mop, precision: 15, scale: 2
      t.decimal :unpaid_compassionate_leave_reduction_mop, precision: 15, scale: 2
      t.decimal :unpaid_maternity_leave_reduction_mop, precision: 15, scale: 2
      t.decimal :pregnant_sick_leave_reduction_mop, precision: 15, scale: 2
      t.decimal :occupational_injury_reduction_mop, precision: 15, scale: 2
      t.decimal :total_salary_hkd, precision: 15, scale: 2
      t.decimal :benefits_hkd, precision: 15, scale: 2
      t.decimal :incentive_hkd, precision: 15, scale: 2
      t.decimal :housing_benefit_hkd, precision: 15, scale: 2
      t.decimal :cover_charge_hkd, precision: 15, scale: 2
      t.decimal :kill_bonus_hkd, precision: 15, scale: 2
      t.decimal :performance_bonus_hkd, precision: 15, scale: 2
      t.decimal :swiping_card_bonus_hkd, precision: 15, scale: 2
      t.decimal :commission_margin_hkd, precision: 15, scale: 2
      t.decimal :collect_accounts_bonus_hkd, precision: 15, scale: 2
      t.decimal :exchange_rate_bonus_hkd, precision: 15, scale: 2
      t.decimal :zunhuadian_hkd, precision: 15, scale: 2
      t.decimal :xinchunlishi_hkd, precision: 15, scale: 2
      t.decimal :project_bonus_hkd, precision: 15, scale: 2
      t.decimal :shangpin_bonus_hkd, precision: 15, scale: 2
      t.decimal :dispatch_bonus_hkd, precision: 15, scale: 2
      t.decimal :recommand_new_guest_bonus_hkd, precision: 15, scale: 2
      t.decimal :typhoon_benefits_hkd, precision: 15, scale: 2
      t.decimal :annual_incentive_payment_hkd, precision: 15, scale: 2
      t.decimal :back_pay_hkd, precision: 15, scale: 2
      t.decimal :total_reduction_hkd, precision: 15, scale: 2
      t.decimal :absenteeism_reduction_hkd, precision: 15, scale: 2
      t.decimal :immediate_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :unpaid_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :unpaid_marriage_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :unpaid_compassionate_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :unpaid_maternity_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :pregnant_sick_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :occupational_injury_reduction_hkd, precision: 15, scale: 2
      t.decimal :paid_sick_leave_reduction_hkd, precision: 15, scale: 2
      t.decimal :late_reduction_hkd, precision: 15, scale: 2
      t.decimal :missing_punch_card_reduction_hkd, precision: 15, scale: 2
      t.decimal :punishment_reduction_hkd, precision: 15, scale: 2

      t.timestamps
    end
  end
end
