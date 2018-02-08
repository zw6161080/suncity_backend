class TrainForAllIndexSerializer < ActiveModel::Serializer
  attributes *Train.create_params.select { |item| item.is_a?(String) }
  attributes :entry_lists_count,
             :final_lists_count
  belongs_to :train_template_type
  def entry_lists_count
    object.entry_lists_count
  end
  def final_lists_count
    object.final_lists_count
  end
end