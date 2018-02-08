class SalaryElementCategorySerializer < ActiveModel::Serializer
  attributes *SalaryElementCategory.column_names
  has_many :salary_elements
end