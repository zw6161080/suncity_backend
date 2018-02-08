class ProfileTableRow

  def initialize(attributes={})
    unless attributes.key?('id')
      attributes['id'] = SecureRandom.uuid
    end

    # attributes is a hash
    @attributes = attributes
  end

  def attributes
    @attributes
  end

  def update(field, value)
    @attributes[field] = value
  end

  def as_json(*args)
    self.attributes.as_json
  end

  def has_attribute?(key)
    attributes.key?(key)
  end

  def attribute_value(key)
    attributes[key]
  end

  def method_missing(method_id, *args, &block)
    method_name = method_id.to_s
    if has_attribute?(method_name)
      attribute_value(method_name)
    else
      super
    end
  end

  def respond_to?(method_id, include_private = false)
    method_name = method_id.to_s
    if has_attribute?(method_name)
      true
    else
      super
    end
  end

end