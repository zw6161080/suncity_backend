class MonthSalaryChangeRecordSerializer < ActiveModel::Serializer
  attributes :id

  belongs_to :user
  belongs_to :original_salary_record
  belongs_to :updated_salary_record
end
