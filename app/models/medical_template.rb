# == Schema Information
#
# Table name: medical_templates
#
#  id                        :integer          not null, primary key
#  chinese_name              :string           not null
#  english_name              :string           not null
#  simple_chinese_name       :string           not null
#  insurance_type            :string           not null
#  balance_date              :datetime         not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  can_be_delete             :boolean
#  undestroyable_forever     :boolean
#  undestroyable_temporarily :boolean
#
# Indexes
#
#  index_medical_templates_on_balance_date         (balance_date)
#  index_medical_templates_on_chinese_name         (chinese_name)
#  index_medical_templates_on_english_name         (english_name)
#  index_medical_templates_on_insurance_type       (insurance_type)
#  index_medical_templates_on_simple_chinese_name  (simple_chinese_name)
#

class MedicalTemplate < ApplicationRecord
  has_many :medical_items, dependent: :destroy
  has_many :medical_insurance_participators

  validates :chinese_name, :english_name, :simple_chinese_name, presence: true
  validates :insurance_type, :balance_date, presence: true

  enum insurance_type: { suncity_insurance:    'medical_template.enum_insurance_type.suncity_insurance',
                         commercial_insurance: 'medical_template.enum_insurance_type.commercial_insurance' }

  def get_json_data(current_template_ids = nil)
    data = self.as_json(include: {medical_items: {include: :medical_item_template}})
    data['in_effect']   = false
    data['user_grades'] = []
    if current_template_ids && current_template_ids.include?(self.id)
      data['in_effect']   = true
      grades = MedicalTemplateSetting.first['sections'].select{|record| record['current_template_id'] == self.id}.map{|section|section['employee_grade']}
      if grades.class == Fixnum
        data['user_grades'] = [grades]
      else
        data['user_grades'] = grades
      end
    end
    data
  end
end
