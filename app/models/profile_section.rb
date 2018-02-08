class ProfileSection
  include ConfigAble

  # 根据config文件里的region字段，判断是否是只属于某一个region
  def belongs_to_region?(region)
    if self.is_attribute_key?('region')
      if self.attributes['region'] == region
        true
      else
        false
      end
    else
      true
    end
  end

  # 根据section类型构建不同的子类
  def self.build(attributes, options)
    section_type = attributes['type']
    case section_type
    when 'fields'
      ProfileFieldsSection.new(attributes, options)
    when 'template'
      ProfileTemplateSection.new(attributes, options)
    else
      ProfileTableSection.new(attributes, options)
    end
  end

  # 根据section类型构建不同的子类
  def self.create_build(attributes, options)
    section_type = attributes['type']
    case section_type
      when 'fields'
        ProfileCreateFieldsSection.new(attributes, options)
      when 'template'
        ProfileTemplateSection.new(attributes, options)
      else
        ProfileTableSection.new(attributes, options)
    end
  end

  # stateless attributes是直接读取于配置文件里，不需要写入数据库
  def stateless_attribute_keys
    %w{key chinese_name english_name simple_chinese_name type}
  end

  # stateful attributes是需要写入数据库的values
  def stateful_attribute_keys
    []
  end

  def stateless_attribtues_as_json
    attributes_as_json(stateless_attribute_keys)
  end

  def stateful_attributes_as_json
    attributes_as_json(stateful_attribute_keys)
  end

  def is_table?
    self.type == 'table'
  end

  def as_json(*args)
    stateful_attributes_as_json.merge stateless_attribtues_as_json
  end

  # reduce to saving in profile
  def to_value_data
    stateful_attributes_as_json.merge(
      attributes.slice('key')
    )
  end

  def on_save
    # on save 的逻辑都在子类中处理了
  end

  private

  def attributes_as_json(attribute_keys)
    res = {}
    attribute_keys.each do |key|
      if self.respond_to? key
        res[key] = self.send(key).as_json
      end
    end
    res
  end
end
