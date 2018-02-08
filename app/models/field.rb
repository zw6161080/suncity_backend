# coding: utf-8
class Field
  include ConfigAble

  # 读取Field配置中的select配置信息
  def select_config
    attributes.dig('meta.select')
  end

  # 对于包含Select信息的Field，可以获取到对应的select对象
  def select
    s = Select.find(select_key) if select_key
    if select_config.is_a?(Hash)
      s.merge_attributes(select_config)
    end
    s
  end

  # 获取Field的value相对应的Option对象
  def select_option_of_value
    res = if value == 'false'
            false
          elsif value == 'true'
            true
          else
            value
          end

    select.option_of_value(res)
  end

  # 获取Field对应的Select对象的key
  def select_key
    if select_config.is_a?(Hash)
      select_config['key']
    else
      select_config
    end
  end

  def value=(new_value)
    add_attribute('value', new_value)
  end

  def section=(section)
    self.add_attribute('section', section)
    if section.respond_to?('supervisor')
      self.supervisor = section.supervisor
    end
  end

  def is_date?
    self.type == 'date'
  end

  def valid_string_date?
    if self.required
      Time.zone.parse(self.value) rescue false
    else
      if self.value.nil?
        true
      else
        Time.zone.parse(self.value) rescue false
      end
    end
  end

  def is_select?
    self.type == 'select'
  end

  def is_radio?
    self.type == 'radio'
  end

  def is_radiofixed?
    self.type == 'radiofixed'
  end

  # 是否是带选项的Field
  def is_selectable?
    is_select? or is_radio? or is_radiofixed?
  end

  # 是否是【选择列模板】中可以选择的Field
  def selectable
    has_attribute?('selectable') and attribute_value('selectable')
  end

  # Field的默认值
  def default
    if self.attributes.key?('default')
      default_value = self.attributes['default']
      # 如果是`Logic#`开头的值，则执行代码动态生成默认值
      if 'Logic#'.in?(default_value)
        default_value = eval(default_value.split('#')[1])
      end
      default_value
    elsif self.is_selectable? and self.select.respond_to?('default')
      self.select.default
    else
      nil
    end
  end

  # get field type
  # default type if string
  def type
    if has_attribute?('type')
      attribute_value('type')
    else
      'string'
    end
  end

  def readonly
    if has_attribute?('readonly')
      attribute_value('readonly')
    else
      false
    end
  end

  def required
    if has_attribute?('required')
      attribute_value('required')
    else
      true
    end
  end

  def value
    if has_attribute?('value')
      attribute_value('value')
    else
      nil
    end
  end

  def as_json
    keys = %w{key chinese_name english_name simple_chinese_name type selectable readonly meta value required default alias_with alias_rule}

    hash = {}

    keys.each do |key|
      if self.respond_to?(key)
        hash[key] = self.send(key)
      end
    end

    if is_selectable?
      hash['select'] = select.as_json
    end
    hash.select do |key, value|
      not value.nil?
    end
  end

  def has_hooks?
    respond_to?('supervisor') and has_attribute?('meta') and meta.key?('hooks')
  end

  def hooks
    if has_hooks?
      meta['hooks']
    else
      nil
    end
  end

  # 调用所有supervisor上对应的`hook`方法
  def call_hooks
    if has_hooks?
      hooks.each do |hook|
        self.supervisor.publish(hook, self.value)
      end
    end
  end

  # 进行Field字段value的合法性验证
  def do_validate
    if self.required and self.value.nil?
      raise LogicError, {message: "#{self.section.chinese_name} 的 #{self.chinese_name} 是必填的"}.to_json
    end
    if self.is_date? && !self.valid_string_date?
      raise LogicError, {message: "#{self.section.chinese_name} 的 #{self.chinese_name} 不是有效的日期"}.to_json
    end
  end

  # save的回调
  def on_save
    if self.respond_to?('section') and (['fields', 'template'].include? self.section.type)
      self.do_validate
      self.call_hooks
    end
  end

  # Field的value的多语言render
  def render_value(lang_key ='chinese_name')

    if is_selectable?
      begin
        option = select_option_of_value
        if option.respond_to?(lang_key)
          option.send(lang_key)
        else
          option.fetch(lang_key)
        end
      rescue ActiveRecord::RecordNotFound, NoMethodError
        value
      end
    else
      value
    end
  end

  def render_hash_value
    if is_selectable?
      begin
        select_option_of_value
      rescue ActiveRecord::RecordNotFound, NoMethodError
        {
          chinese_name: value,
          simple_chinese_name: value,
          english_name: value,
        }
      end
    else
      {
        chinese_name: value,
        simple_chinese_name: value,
        english_name: value,
      }
    end
  end
end
