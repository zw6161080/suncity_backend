class CreateAnnualAwardReports < ActiveRecord::Migration[5.0]
  def change
    create_table :annual_award_reports do |t|
      t.datetime :year_month
      t.decimal :annual_attendance_award_hkd, precision: 15, scale: 2
      t.string :annual_bonus_grant_type
      t.jsonb :grant_type_rule
      t.decimal :absence_deducting, precision: 15, scale: 2
      t.decimal :notice_deducting, precision: 15, scale: 2
      t.decimal :late_5_times_deducting, precision: 15, scale: 2
      t.decimal :sign_card_deducting, precision: 15, scale: 2
      t.decimal :one_letter_of_warning_deducting, precision: 15, scale:2
      t.decimal :two_letters_of_warning_deducting, precision: 15, scale:2
      t.decimal :each_piece_of_awarding_deducting, precision: 15, scale:2
      t.string :method_of_settling_accounts
      t.datetime :award_date


      t.timestamps
    end
  end
end
