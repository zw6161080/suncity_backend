class CreateAnnualAwardReportItems < ActiveRecord::Migration[5.0]
  def change
    create_table :annual_award_report_items do |t|
      t.integer :annual_award_report_id
      t.integer :user_id
      t.boolean :add_double_pay
      t.decimal :double_pay_hkd, precision: 15, scale: 2
      t.decimal :double_pay_alter_hkd, precision: 15, scale: 2
      t.decimal :double_pay_final_hkd, precision: 15, scale: 2
      t.boolean :add_end_bonus
      t.decimal :end_bonus_hkd, precision: 15, scale: 2
      t.integer :praise_times
      t.decimal :end_bonus_add_hkd, precision: 15, scale: 2
      t.integer :absence_times
      t.integer :notice_times
      t.integer :late_times
      t.integer :lack_sign_card_times
      t.integer :punishment_times
      t.decimal :de_end_bonus_for_absence_hkd, precision: 15, scale: 2
      t.decimal :de_bonus_for_notice_hkd, precision: 15, scale: 2
      t.decimal :de_end_bonus_for_late_hkd,  precision: 15, scale: 2
      t.decimal :de_end_bonus_for_sign_card_hkd, precision: 15, scale: 2
      t.decimal :de_end_bonus_for_punishment_hkd, precision: 15, scale: 2
      t.decimal :de_bonus_total_hkd, precision:15, scale: 2
      t.decimal :end_bonus_final_hkd, precision: 15, scale: 2
      t.boolean :present_at_duty_first_half
      t.decimal :annual_at_duty_basic_hkd, precision: 15, scale: 2
      t.decimal :annual_at_duty_final_hkd, precision: 15, scale: 2
      t.timestamps
    end
  end
end
