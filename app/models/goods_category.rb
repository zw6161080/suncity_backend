# == Schema Information
#
# Table name: goods_categories
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  unit                :string
#  price_mop           :decimal(15, 2)
#  distributed_count   :integer
#  returned_count      :integer
#  unreturned_count    :integer
#  user_id             :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_goods_categories_on_user_id  (user_id)
#

class GoodsCategory < ApplicationRecord
  include StatementAble

  belongs_to :user

  scope :by_goods_name, -> (name) {
    where('goods_categories.chinese_name = :name OR goods_categories.english_name = :name', name: name)
  }

  class << self
    def unit_options
      self.all.distinct.pluck(:unit)
    end
  end
end
