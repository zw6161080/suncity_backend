# == Schema Information
#
# Table name: train_classes
#
#  id         :integer          not null, primary key
#  time_begin :datetime
#  time_end   :datetime
#  row        :integer
#  title_id   :integer
#  train_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_train_classes_on_title_id  (title_id)
#  index_train_classes_on_train_id  (train_id)
#

class TrainClass < ApplicationRecord
  include TrainClassValidators
  validates_with TrainClassWithRightTitleValidator
  belongs_to :train
  belongs_to :title
  has_and_belongs_to_many :users
  has_and_belongs_to_many :departments

  def get_json_data
    record = self.as_json(include: [
        {train: {methods: :train_template}},
        :title
    ])
    record[:date] = self[:time_begin].strftime('%Y/%m/%d')
    record
  end

end
