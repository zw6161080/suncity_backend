module CardProfileHelper
  include ValueTransferHelper
  def get_section_by_field(field_key)
    Config.get(:constants_collection)['CardProfile'].select do|key, value|
      value.include? field_key
    end.keys.first rescue nil
  end

  def get_action_type_by_fields(initial_value, final_value)
    if initial_value.to_s.empty? && !final_value.to_s.empty?
      'add'
    elsif !initial_value.to_s.empty? && final_value.to_s.empty?
      'delete'
    else
      'edit'
    end
  end

  def get_field_value(field_key, value_key)
    Config.get(:card_profile_field_selects).select{|key,value| key == field_key}['status']['options'].select{|hash| hash['key']== value_key}.first.reject{|key, value| key == 'key'}  rescue nil
  end

  def get_attachment_field_value(field_key, value_key)
    Config.get(:card_profile_attachment_field_selects).select{|key,value| key == field_key}['status']['options'].select{|hash| hash['key']== value_key}.first.reject{|key, value| key == 'key'}  rescue nil
  end

  private
  def final_field_value(field_key,value_key)
    if  get_field_value(field_key, value_key)
      get_field_value(field_key, value_key)
    else
      single_field_to_multi_language_hash(value_key)
    end
  end

  def final_attachment_field_value(field_key,value_key)
    if  get_attachment_field_value(field_key, value_key)
      get_attachment_field_value(field_key, value_key)
    else
      single_field_to_multi_language_hash(value_key)
    end
  end
end