class GoodsCategorySerializer < ActiveModel::Serializer
  attributes :id,
             :chinese_name,
             :english_name,
             :simple_chinese_name,
             :unit,
             :price_mop,
             :distributed_count,
             :returned_count,
             :unreturned_count,
             :created_at

  has_one :user

end
