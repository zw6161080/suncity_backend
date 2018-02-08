# == Schema Information
#
# Table name: salary_column_templates
#
#  id                    :integer          not null, primary key
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  default               :boolean
#  original_column_order :integer          default([]), is an Array
#

class SalaryColumnTemplate < ApplicationRecord
  has_and_belongs_to_many :salary_columns

  after_create :initial_default_template

  def self.load_predefined
    self.first_or_create do |template|
      template.name = 'Default'
      template.salary_columns << SalaryColumn.all.where.not(id: 0).where.not('id > 1000')
      template.original_column_order = SalaryColumn.all.where.not(id: 0).where.not('id > 1000').order(:order_no => :asc).ids
      template.save
    end
  end

  def initial_default_template
    if SalaryColumnTemplate.where(default: true).count < 1
      self.update_columns(default: true)
    end
  end

  def set_default_template
    SalaryColumnTemplate.where(default: true).each do |item|
      item.update_columns(default: false)
    end
    self.update_columns(default: true)
  end

  def add_salary_column(column_array)
    self.salary_columns << SalaryColumn.where(id: column_array)
    self.original_column_order = column_array
    self.save
  end

  def update_salary_column(column_array)
    self.salary_columns.clear
    self.salary_columns << SalaryColumn.where(id: column_array)
    self.original_column_order = column_array
    self.save
  end
end
