class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def full_error_message
    errors.full_messages.join("、")
  end

  def self.create_params
    self.columns.map(&:name) - %w(id created_at updated_at)
  end

  def self.select_language
    if I18n.locale == 'zh-HK'.to_sym
      :chinese_name
    elsif I18n.locale == 'zh-CN'.to_sym
      :simple_chinese_name
    else
      :english_name
    end
  end

end
