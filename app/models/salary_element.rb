# == Schema Information
#
# Table name: salary_elements
#
#  id                         :integer          not null, primary key
#  chinese_name               :string
#  english_name               :string
#  simple_chinese_name        :string
#  key                        :string
#  salary_element_category_id :integer
#  display_template           :string
#  comment                    :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_salary_elements_on_salary_element_category_id  (salary_element_category_id)
#
# Foreign Keys
#
#  fk_rails_e2f68d4376  (salary_element_category_id => salary_element_categories.id)
#

class SalaryElement < ApplicationRecord
  belongs_to :salary_element_category
  has_many :salary_element_factors, dependent: :destroy
end
