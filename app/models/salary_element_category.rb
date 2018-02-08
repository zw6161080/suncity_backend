# == Schema Information
#
# Table name: salary_element_categories
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  key                 :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

class SalaryElementCategory < ApplicationRecord
  has_many :salary_elements, dependent: :destroy

  def self.load_predefined
    all_categories_config = Config.get('salary_element_categories')
    all_elements_config = Config.get('salary_elements')
    all_factors_config = Config.get('salary_element_factors')

    ActiveRecord::Base.transaction do
      all_categories_config.each do |category_key, category_config|
        # create category
        category = self.find_or_create_by(key: category_key)
        category.update(category_config.except('elements'))

        # create elements for category
        category_config['elements']&.each do |element_key|
          element_config = all_elements_config[element_key]
          element = category
                      .salary_elements
                      .find_or_create_by(key: element_key)
          element.update(element_config.except('factors'))

          # create factors for element
          element_config['factors']&.each do |factor_key|
            factor_config = all_factors_config[factor_key]
            factor_config_without_value = factor_config.except(:numerator, :denominator, :value)

            factor = element
                       .salary_element_factors
                       .find_or_create_by(key: factor_key)
            if factor.numerator.nil? && factor.denominator.nil? && factor.value.nil?
              factor.update(factor_config)
            else
              factor.update(factor_config_without_value)
            end

            factor.save
          end
          element.save
        end
        category.save
      end
    end
  end

  def self.reset_predefined
    all_categories_config = Config.get('salary_element_categories')
    all_elements_config = Config.get('salary_elements')
    all_factors_config = Config.get('salary_element_factors')

    ActiveRecord::Base.transaction do
      all_categories_config.each do |category_key, category_config|
        # create category
        category = self.find_or_create_by(key: category_key)
        category.update(category_config.except('elements'))

        # create elements for category
        category_config['elements']&.each do |element_key|
          element_config = all_elements_config[element_key]
          element = category
                      .salary_elements
                      .find_or_create_by(key: element_key)
          element.update(element_config.except('factors'))

          # create factors for element
          element_config['factors']&.each do |factor_key|
            factor_config = all_factors_config[factor_key]
            # factor_config_without_value = factor_config.except(:numerator, :denominator, :value)

            factor = element
                       .salary_element_factors
                       .find_or_create_by(key: factor_key)
            # if factor.numerator.nil? && factor.denominator.nil? && factor.value.nil?
            factor.update(factor_config)
            # else
            #   factor.update(factor_config_without_value)
            # end

            factor.save
          end
          element.save
        end
        category.save
      end
    end
  end

end
