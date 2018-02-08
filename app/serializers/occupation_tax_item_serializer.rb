class OccupationTaxItemSerializer < ActiveModel::Serializer
  attributes *OccupationTaxItem.create_params, :id
  belongs_to :user
  belongs_to :department
  belongs_to :position

  def year_income_mop
    object.year_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def year_payable_tax_mop
    object.year_payable_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def year_paid_tax_mop
    object.year_paid_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_4_tax_mop_after_adjust
    object.quarter_4_tax_mop_after_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def double_pay_bonus_and_award
    object.double_pay_bonus_and_award&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def quarter_1_tax_mop_after_adjust
    object.quarter_1_tax_mop_after_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_2_tax_mop_after_adjust
    object.quarter_2_tax_mop_after_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_3_tax_mop_after_adjust
    object.quarter_3_tax_mop_after_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def quarter_1_tax_mop_before_adjust
    object.quarter_1_tax_mop_before_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_2_tax_mop_before_adjust
    object.quarter_2_tax_mop_before_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_3_tax_mop_before_adjust
    object.quarter_3_tax_mop_before_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_4_tax_mop_before_adjust
    object.quarter_4_tax_mop_before_adjust&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def quarter_1_income_mop
    object.quarter_1_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_2_income_mop
    object.quarter_2_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_3_income_mop
    object.quarter_3_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def quarter_4_income_mop
    object.quarter_4_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_1_tax_mop
    object.month_1_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_2_tax_mop
    object.month_2_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_3_tax_mop
    object.month_3_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_4_tax_mop
    object.month_4_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_5_tax_mop
    object.month_5_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_6_tax_mop
    object.month_6_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_7_tax_mop
    object.month_7_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_8_tax_mop
    object.month_8_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_9_tax_mop
    object.month_9_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_10_tax_mop
    object.month_10_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_11_tax_mop
    object.month_11_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_12_tax_mop
    object.month_12_tax_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_1_income_mop
    object.month_1_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_2_income_mop
    object.month_2_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_3_income_mop
    object.month_3_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_4_income_mop
    object.month_4_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_5_income_mop
    object.month_5_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_6_income_mop
    object.month_6_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_7_income_mop
    object.month_7_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_8_income_mop
    object.month_8_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_9_income_mop
    object.month_9_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_10_income_mop
    object.month_10_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end


  def month_11_income_mop
    object.month_11_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

  def month_12_income_mop
    object.month_12_income_mop&.round(0)&.to_s&.sub(/\.\d*/, '')
  end

end
