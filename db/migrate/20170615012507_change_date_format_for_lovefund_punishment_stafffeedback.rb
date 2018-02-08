class ChangeDateFormatForLovefundPunishmentStafffeedback < ActiveRecord::Migration[5.0]
  def change

    remove_column :staff_feedbacks, :feedback_date, :date
    add_column :staff_feedbacks, :feedback_date, :datetime

    remove_column :punishments, :punishment_date, :date
    remove_column :punishments, :punishment_result_validity_end_date, :date
    remove_column :punishments, :incident_suspended_date, :date
    remove_column :punishments, :reinstated_date, :date
    remove_column :punishments, :incident_money_involved, :float

    add_column :punishments, :punishment_date, :datetime
    add_column :punishments, :punishment_result_validity_end_date, :datetime
    add_column :punishments, :incident_suspended_date, :datetime
    add_column :punishments, :reinstated_date, :datetime
    add_column :punishments, :incident_money_involved, :decimal, precision:10, scale:2


    remove_column :love_funds, :participate_date, :date
    remove_column :love_funds, :cancel_date, :date

    add_column :love_funds, :participate_date, :datetime
    add_column :love_funds, :cancel_date, :datetime
  end
end
