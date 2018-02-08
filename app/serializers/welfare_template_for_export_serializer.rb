class WelfareTemplateForExportSerializer < ActiveModel::Serializer
  attributes *WelfareTemplate.create_params, :belongs_to_string

  def belongs_to_string
    object.belongs_to_string
  end

end
