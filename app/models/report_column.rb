# == Schema Information
#
# Table name: report_columns
#
#  id                                      :integer          not null, primary key
#  report_id                               :integer
#  key                                     :string
#  chinese_name                            :string
#  english_name                            :string
#  simple_chinese_name                     :string
#  value_type                              :string
#  data_index                              :string
#  search_type                             :string
#  sorter                                  :boolean
#  options_type                            :string
#  options_predefined                      :jsonb
#  options_endpoint                        :string
#  source_data_type                        :string
#  source_model                            :string
#  source_model_user_association_attribute :string
#  join_attribute                          :string
#  source_attribute                        :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  user_source_model_association_attribute :string
#  option_attribute                        :string
#  value_format                            :string
#
# Indexes
#
#  index_report_columns_on_report_id  (report_id)
#
# Foreign Keys
#
#  fk_rails_53bbfb1f7c  (report_id => reports.id)
#

class ReportColumn < ApplicationRecord
  belongs_to :report
  enum value_type: {
    string_value: 'string_value',
    select_value: 'select_value',
    bool_value: 'bool_value',
    date_value: 'date_value',
    obj_value: 'obj_value'
  }
  enum search_type: {
    null: 'null',
    search: 'search',
    screen: 'screen',
    date: 'date'
  }
  enum options_type: {
    api: 'api',
    value: 'value',
    predefined: 'predefined',
  }
  enum source_data_type: {
    model: 'model',
    profile: 'profile',
  }

  def options
    return nil unless self.search_type == 'screen'

    if %w(api value).include? self.options_type
      model_class = self.source_model.classify.safe_constantize
      model_class.distinct.pluck(self.option_attribute)
    elsif self.options_type == 'predefined'
      self.options_predefined
    else
      nil
    end
  end
end
