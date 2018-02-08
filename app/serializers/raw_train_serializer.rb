class RawTrainSerializer < ActiveModel::Serializer
  attributes *Train.column_names - %w(grade), :train_template


  def train_template
    object.train_template
  end
end