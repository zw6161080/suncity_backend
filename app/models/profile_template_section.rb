class ProfileTemplateSection < ProfileSection

  def stateless_attribute_keys
    super.push('fields')
  end

  def stateful_attribute_keys
    %w{field_values show_outside}
  end

  # 根据 field_key 创建 Field 实体对象
  def create_field_by_key(field_key)
    field = Field.find(field_key)
    # setting filed value if it has
    if self.field_has_value?(field_key)
      field.value = self.field_value(field_key)
    end
    # field can access section
    field.section = self
    field
  end

  def fields
    field_keys.map do |field_key|
      create_field_by_key(field_key)
    end
  end

  def selectable_fields
    fields.select(&:selectable)
  end

  def field_keys
    attributes.dig(fields_key_path)
  end

  def field_has_value?(field_key)
    self.respond_to?('field_values') and !self.field_values.nil? and self.field_values.key?(field_key)
  end

  def field_value(field_key)
    if self.field_has_value?(field_key)
      self.field_values[field_key]
    else
      nil
    end
  end

  def find_field(field_key)
    fields.find do |field|
      field.key == field_key
    end
  end

  def edit_field(params)
    set_values('field_values', {}) if self.field_values.nil?
    self.field_values[params['field']] = params['new_value']
  end

  def set_values(name,values)
    add_attribute(name, values)
  end

  def merge_params(params)
    set_values('field_values',params['field_values'])
    if params['hide_column']
      set_values('hide_column',params['hide_column'])
    end

    set_values('show_outside',params['show_outside']) if params['show_outside']
  end

  def fields_key_path
    key_path = []
    if self.respond_to?('multi_regions')
      key_path.push('regions')
      key_path.push(self.region)
    end

    key_path.push('fields')

    key_path.join('.')
  end

  def on_save
    fields.each(&:on_save)
  end

end
