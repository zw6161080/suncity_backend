# == Schema Information
#
# Table name: salary_columns
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  column_type         :string
#  function            :string
#  add_deduct_type     :string
#  tax_type            :string
#  value_type          :string
#  category            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  order_no            :integer
#

class SalaryColumn < ApplicationRecord
  validates :chinese_name, :english_name, :simple_chinese_name, presence: true, unless: :is_pay_slip?
  validates :column_type, inclusion: {in: %w(fixed function)}, unless: :is_pay_slip?
  validates :add_deduct_type, inclusion: {in: %w(add deduct none)}, unless: :is_pay_slip?
  validates :tax_type, inclusion: {in: %w(changed not_changed)}, unless: :is_pay_slip?
  validates :value_type, inclusion: {in: %w(decimal string integer date object boolean)}, unless: :is_pay_slip?
  validates :category, inclusion: {
    in: %w(basic attendance salary_column annual_award salary_list others data_basic_salary data_except_basic_salary
status pay_slip)
  }

  has_and_belongs_to_many :salary_column_templates


  def is_pay_slip?
    self.category == 'pay_slip'
  end

  def self.generate
    remove_columns = SalaryColumn.where(id: [157, 169])
    remove_columns.destroy_all unless remove_columns.empty?
    Config.get(:salary_column)['salary_column'].each do |item|
      result = SalaryColumn.find_or_create_by(id: item['id'])
      SalaryColumn.create_params.each do |key|
        result[key] = item[key] if item[key]
      end
      result.save!
      # unless result
      #   result = SalaryColumn.find(item['id']) rescue nil
      #   if result
      #     result.update(item)
      #   else
      #     self.create(item)
      #   end
      # else
      #   # result.update(item)
      # end
    end
  end
end
