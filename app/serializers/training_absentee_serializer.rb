class TrainingAbsenteeSerializer < ActiveModel::Serializer

  attributes :id,
             :user_id,
             :train_class_id,
             :has_submitted_reason,
             :has_been_exempted,
             :absence_reason,
             :submit_date,
             :train_date,
             :train_class_time

  belongs_to :user
  belongs_to :train_class

  def train_date
    object.decorate_train_date
  end

  def train_class_time
    object.decorate_train_class_time
  end

  def submit_date
    object.submit_date.strftime('%Y/%m/%d %H:%M') if object.submit_date
  end
end
