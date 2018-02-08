class AnnualAwardReportItemSerializer < ActiveModel::Serializer
  attributes *AnnualAwardReportItem.column_names
  belongs_to :user
  belongs_to :department
  belongs_to :position
  def work_days_this_year
    object.work_days_this_year.to_s.sub(/\.\d*/, '')
  end

  def deducted_days
    object.deducted_days.to_s.sub(/\.\d*/, '')
  end

  def double_pay_hkd
    object.double_pay_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def double_pay_alter_hkd
    object.double_pay_alter_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def double_pay_final_hkd
    object.double_pay_final_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def end_bonus_hkd
    object.end_bonus_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def end_bonus_add_hkd
    object.end_bonus_add_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def de_end_bonus_for_absence_hkd
    object.de_end_bonus_for_absence_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def de_bonus_for_notice_hkd
    object.de_bonus_for_notice_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def de_end_bonus_for_late_hkd
    object.de_end_bonus_for_late_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def de_end_bonus_for_sign_card_hkd
    object.de_end_bonus_for_sign_card_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def de_end_bonus_for_punishment_hkd
    object.de_end_bonus_for_punishment_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def de_bonus_total_hkd
    object.de_bonus_total_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def end_bonus_final_hkd
    object.end_bonus_final_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def annual_at_duty_basic_hkd
    object.annual_at_duty_basic_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def annual_at_duty_final_hkd
    object.annual_at_duty_final_hkd&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

end
