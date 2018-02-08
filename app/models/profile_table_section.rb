class ProfileTableSection < ProfileSection

  def stateless_attribute_keys
    super.push('schema')
  end

  def stateful_attribute_keys
    %w{rows hide_column}
  end

  # schema的 key path
  def schema_key_path
    'table.schema'
  end

  # 表头所有的field key
  def schema_keys
    attributes.dig(schema_key_path)
  end

  # 表头所有的Field
  def schema
    schema_keys.map do |schema_key|
      Field.find(schema_key)
    end
  end

  # 返回表头中某一个key对应的Field
  def find_schema(key)
    if key.in? schema_keys
      Field.find(key)
    else
      nil
    end
  end

  def set_rows(rows)
    row_collection = ProfileTableRowCollection.new(rows)
    add_attribute('rows', row_collection)
  end

  def add_row(params)
    rows.send('add_row', params)
  end

  def edit_row_fields(params)
      rows.send('edit_row_fields', params)
  end

  def remove_row(params)
    rows.send('remove_row', params)
  end

  def add_attribute(key, value)
    @attributes[key] = value
  end

  # merge stateful data
  def merge_params(params)
    set_rows(params['rows'])
    if params['hide_column']
      set_values('hide_column',params['hide_column'])
    end
  end

  def set_values(name,values)
    add_attribute(name, values)
  end

  def edit_field(params)
    set_values('hide_column', {}) if (!@attributes.has_key?('hide_column') or self.hide_column.nil?)
    self.add_attribute('hide_column',params['new_value'])
  end

end
