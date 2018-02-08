class ApplicationJob < ActiveJob::Base
  def select_language
    if I18n.locale == 'zh-HK'.to_sym
      :chinese_name
    elsif I18n.locale == 'zh-CN'.to_sym
      :simple_chinese_name
    else
      :english_name
    end
  end
end
