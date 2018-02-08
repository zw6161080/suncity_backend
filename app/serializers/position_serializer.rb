class PositionSerializer < ActiveModel::Serializer
  attributes *Position.column_names
  def chinese_name
    object.raw_chinese_name
  end
  def english_name
    object.raw_english_name
  end
  def simple_chinese_name
    object.raw_simple_chinese_name
  end
end