# == Schema Information
#
# Table name: salary_element_factors
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  key                 :string
#  salary_element_id   :integer
#  factor_type         :string
#  numerator           :decimal(10, 2)
#  denominator         :decimal(10, 2)
#  value               :decimal(10, 2)
#  comment             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_salary_element_factors_on_salary_element_id  (salary_element_id)
#
# Foreign Keys
#
#  fk_rails_47cb8d64ae  (salary_element_id => salary_elements.id)
#

class SalaryElementFactor < ApplicationRecord
  belongs_to :salary_element
  enum factor_type: { fraction: 'fraction', value: 'value' }

  def self.batch_update(updates)
    update_param_names = [:numerator, :denominator, :value]

    updates.each do |params|
      self
        .find(params[:id])
        .update(update_param_names.map { |name| [name, params[name]] }.to_h)
    end
  end
end
