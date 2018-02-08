class WelfareTemplateForJobTransferSerializer < ActiveModel::Serializer
  attributes :id, *WelfareTemplate.create_params, :chinese_name, :english_name, :simple_chinese_name

  def chinese_name
    object.template_chinese_name
  end

  def simple_chinese_name
    object.template_chinese_name
  end

  def english_name
    object.template_chinese_name
  end
end
