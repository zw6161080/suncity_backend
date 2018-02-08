# coding: utf-8
module ConfigAble
  module ClassMethods

    # 获取配置文件里所有的实体对象列表
    def all(options={})
      raw_config.map do |key, attributes|
        attributes['key'] = key
        self.build(attributes, options)
      end
    end

    def create_all(options={})
      create_raw_config.map do |key, attributes|
        attributes['key'] = key
        self.create_build(attributes, options)
      end
    end

    # 自动根据类名读取对应的配置文件，配置文件名根据类名的CamelCase改为underscore_style
    def raw_config
      # undefine config file path
      # using class name instead
      unless self.respond_to?(:config_file)
        config_file_name = ActiveSupport::Inflector.tableize(self.name)
        define_config_file(config_file_name)
      end
      Config.get(self.config_file)
    end

    def create_raw_config
      # undefine config file path
      # using class name instead
      unless self.respond_to?(:create_config_file)
        create_config_file_name = ActiveSupport::Inflector.tableize(self.name)
        define_create_config_file(create_config_file_name)
      end
      Config.get(self.create_config_file)
    end

    # Helper method，定义config_file的类方法
    def define_config_file(file_name)
      self.send(:define_singleton_method, 'config_file') {file_name}
    end

    # Helper method，定义config_file的类方法
    def define_create_config_file(file_name)
      self.send(:define_singleton_method, 'create_config_file') {"create_"+file_name}
    end

    # 根据attributes和options构建实体对象
    def build(attributes, options)
      self.new(attributes, options)
    end

    # 根据attributes和options构建实体对象
    def create_build(attributes, options)
      self.new(attributes, options)
    end

    # 根据key来查找配置文件中属性，并构建实体对象
    def find(key, options={})
      attributes = raw_config[key]

      if attributes.nil?
        #config 未找到 key，判断是否是Logic
        puts self.config_file
        puts self
        puts "#{key} Not Found"
        puts raw_config
      end

      attributes['key'] = key
      self.build(attributes, options)
    end

    # 根据key来查找配置文件中属性，并构建实体对象
    def create_find(key, options={})
      attributes = create_raw_config[key]

      if attributes.nil?
        #config 未找到 key，判断是否是Logic
        puts "#{key} Not Found"
        puts create_raw_config
      end

      attributes['key'] = key
      self.build(attributes, options)
    end

    # 根据keys来查找配置文件中属性，并构建实体对象列表
    def find_in(keys)
      keys.map do |key|
        self.find(key)
      end
    end
  end

  module InstanceMethods
    def initialize(attributes, options={})
      @options = options.with_indifferent_access
      @attributes = attributes.with_indifferent_access
    end

    def attributes
      @attributes
    end

    def initialized_options
      @options
    end

    def add_attribute(key, value)
      @attributes[key] = value
    end

    def merge_attributes(params)
      @attributes.merge!(params)
    end

    # 为调用hook方法准备
    def supervisor=(supervisor)
      add_attribute('supervisor', supervisor)
    end

    def is_attribute_key?(key)
      attributes.key?(key)
    end

    def is_option_key?(key)
      initialized_options.key?(key)
    end

    def has_attribute?(key)
      is_attribute_key?(key) or is_option_key?(key)
    end

    def attribute_value(key)
      if is_attribute_key?(key)
        attributes[key]
      elsif is_option_key?(key)
        initialized_options[key]
      else
        nil
      end
    end

    # 可以直接通过accessor访问attributes
    def method_missing(method_id, *args, &block)
      method_name = method_id.to_s
      if has_attribute?(method_name)
        attribute_value(method_name)
      else
        super
      end
    end

    # 可以直接通过accessor访问attributes, fix respond_to?
    def respond_to?(method_id, include_private = false)
      method_name = method_id.to_s
      if has_attribute?(method_name)
        true
      else
        super
      end
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
