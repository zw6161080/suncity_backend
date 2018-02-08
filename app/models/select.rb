class Select
  include ConfigAble

  # NOTE(zhangmeng): 其实可以不用定义
  # 通过ConfigAble的method_missing方法就可以读取attribute_value
  def type
    attribute_value('type')
  end

  def is_api_select?
    type == 'api'
  end

  def option_of_value(value)
    if is_api_select?
      model = endpoint_to_model
      model.find(value)
    else
      options.find do |option|
        option['key'] == value
      end
    end
  end

  def as_json
    keys = %w{options default type endpoint}
    attributes.select {|key, value| keys.include?(key)}
  end

  # 获取所有select的选项hash
  def self.get_options(key)
    self.find(key.to_s).attributes.fetch("options", {})
  end

  # 获取特定key的选项对象
  def self.get_option(key, option)
    get_options(key).select{|s| s['key'] == option.to_s }.last
  end

  private
  # 获取endpoint对应的Model
  def endpoint_to_model
    endpoint.gsub('/', '').singularize.classify.constantize
  end
end
