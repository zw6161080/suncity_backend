class GoodsSigningSerializer < ActiveModel::Serializer

  attributes :id,
             :distribution_date,
             :goods_status,
             :career_entry_date,
             :goods_category,
             :distribution_count_with_unit,
             :distribution_total_value,
             :sign_date,
             :return_date,
             :distributor,
             :remarks,
             :goods_category_id

  has_one :user
  has_one :distributor
  has_one :goods_category

  def distribution_count_with_unit
    "#{object.distribution_count} #{object.goods_category.unit}"
  end

  def career_entry_date
    object.user.career_entry_date
  end

end
