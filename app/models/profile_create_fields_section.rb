class ProfileCreateFieldsSection < ProfileSection

  def stateless_attribute_keys
    super.push('fields')
  end

  def stateful_attribute_keys
    %w{field_values show_outside}
  end

  # 返回Fields的keypath，主要会是会考虑多地区的问题
  def fields_key_path
    key_path = []
    # 如果是支持多区域，则需要根据区域取相关配置的fields
    if self.respond_to?('multi_regions')
      key_path.push('regions')
      key_path.push(self.region)
    end
    key_path.push('fields')
    key_path.join('.')
  end

  # 读取section配置文件中所有的field key
  def field_keys
    attributes.dig(fields_key_path)
  end

  # 创建并返回Section内所有Field的实体对象，（如果有value，则返回的Field对象也包含此value）
  def fields
    field_keys.map do |field_key|
      create_field_by_key(field_key)
    end
  end

  def selectable_fields
    fields.select(&:selectable)
  end

  # 根据field key创建Field实体对象，（如果有value包含在内，也同样会返回value）
  def create_field_by_key(field_key)
    field = Field.create_find(field_key)
    # setting filed value if it has
    if self.field_has_value?(field_key)
      field.value = self.field_value(field_key)
    end
    # field can access section
    field.section = self
    field
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

  def set_values(name, values)
    add_attribute(name, values)
  end

  # merge stateful data
  def merge_params(params)
    set_values('field_values', params['field_values'])
    if params['hide_column']
      set_values('hide_column', params['hide_column'])
    end

    set_values('show_outside', params['show_outside']) if params['show_outside']
  end

  def on_save
    fields.each(&:on_save)
  end

end