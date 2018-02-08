module ValueTransferHelper
  def single_field_to_multi_language_hash(value)
    {
        chinese_name: value,
        simple_chinese_name: value,
        english_name: value,
    }
  end
end