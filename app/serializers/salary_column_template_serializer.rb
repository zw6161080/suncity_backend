class SalaryColumnTemplateSerializer < ActiveModel::Serializer
  attributes *SalaryColumnTemplate.column_names, :salary_columns
  def salary_columns
    object.salary_columns.where.not(id: 0).where.not('id > 1000')
  end
end
