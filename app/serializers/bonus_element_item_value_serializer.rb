class BonusElementItemValueSerializer < ActiveModel::Serializer
  attributes :id,
             :bonus_element_id,
             :bonus_element_item_id,
             :value_type,
             :shares,
             :per_share,
             :amount,
             :subtype,
             :basic_salary

  def shares
    object.shares.round(2) if object.shares
  end

  def per_share
    if object.bonus_element.key == 'performance_bonus'
      object.per_share.round(4) if object.per_share
    else
      object.per_share.round(2) if object.per_share
    end
  end

  def amount
    object.amount.round(0) if object.amount
  end
end
