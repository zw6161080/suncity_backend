class SalaryTemplateSerializer < ActiveModel::Serializer
  attributes :id, :belongs_to, :chinese_name, :english_name, :simple_chinese_name

  def chinese_name
    object.template_chinese_name
  end

  def simple_chinese_name
    object.template_simple_chinese_name
  end

  def english_name
    object.template_english_name
  end

  def template_name
    object.template_chinese_name
  end
end
