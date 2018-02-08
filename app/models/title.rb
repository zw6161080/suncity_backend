# == Schema Information
#
# Table name: titles
#
#  id         :integer          not null, primary key
#  name       :string
#  col        :integer
#  train_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_titles_on_train_id  (train_id)
#

class Title < ApplicationRecord
  include TitleValidators
  belongs_to :train
  has_many :train_classes
  has_and_belongs_to_many :users
  validates_with TitleWithRightRowValidator
end
