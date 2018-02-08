# == Schema Information
#
# Table name: medical_template_settings
#
#  id         :integer          not null, primary key
#  sections   :jsonb
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class MedicalTemplateSetting < ApplicationRecord
  before_update :remove_limitation
  after_update :add_limitation
  def self.auto_update
    medical_template_setting =  MedicalTemplateSetting.first
    medical_template_setting.update_with_params(medical_template_setting)
  end

  def update_with_params(medical_template_setting_params)
    sections = medical_template_setting_params.as_json['sections'].map {|hash|
      unless hash['effective_date'].nil? || hash['impending_template_id'].nil?
        if Time.zone.parse(hash['effective_date']) < Time.zone.now.end_of_day
          hash['current_template_id'] = hash['impending_template_id']
          hash['impending_template_id'] = hash['effective_date'] = nil
        end
      end
      hash
    }
    self.update(sections: sections)
  end

  def remove_limitation
    old_impending_medical_template_ids = MedicalTemplateSetting.first.sections.pluck('impending_template_id')
    old_impending_medical_template_ids.each do |item|
      if item.is_a?(Integer) || (item.is_a?(String)&&item.length>0)
        template = MedicalTemplate.find(item.to_i)
        template.can_be_delete             = !template.undestroyable_forever
        # template.can_be_delete             = true
        # template.undestroyable_forever     = false
        template.undestroyable_temporarily = false
        template.save!
      end
    end
  end

  def add_limitation
    self.sections.each do |record|
      if record['current_template_id'].is_a?(Integer) || (record['current_template_id'].is_a?(String)&&record['current_template_id'].length>0)
        current_medical_template = MedicalTemplate.find(record['current_template_id'].to_i)
        current_medical_template.can_be_delete             = false
        current_medical_template.undestroyable_forever     = true
        current_medical_template.undestroyable_temporarily = true
        current_medical_template.save!
      end
      if record['impending_template_id'].is_a?(Integer) || (record['impending_template_id'].is_a?(String)&&record['impending_template_id'].length>0)
        impending_medical_template = MedicalTemplate.find(record['impending_template_id'].to_i)
        impending_medical_template.can_be_delete             = false
        # impending_medical_template.undestroyable_forever     = false
        impending_medical_template.undestroyable_temporarily = true
        impending_medical_template.save!
      end
    end
  end


  def self.load_predefined
    self.first_or_create(sections: [
        { employee_grade: 1, current_template_id: nil, impending_template_id: nil, effective_date: nil },
        { employee_grade: 2, current_template_id: nil, impending_template_id: nil, effective_date: nil },
        { employee_grade: 3, current_template_id: nil, impending_template_id: nil, effective_date: nil },
        { employee_grade: 4, current_template_id: nil, impending_template_id: nil, effective_date: nil },
        { employee_grade: 5, current_template_id: nil, impending_template_id: nil, effective_date: nil }])
  end

  def self.auto_take_effect
    new_parameters = { sections: [] }
    self.first[:sections].each do |record|
      if record['effective_date'].is_a?(String) && record['effective_date'].length>=8
        the_day = (Time.zone.parse(record['effective_date'].to_s)).beginning_of_day
        if Time.zone.now >= the_day
          record['current_template_id']   = record['impending_template_id'].to_i
          record['impending_template_id'] = nil
          record['effective_date']        = nil
          target = MedicalTemplate.find(record['current_template_id'])
          target.can_be_delete             = false
          target.undestroyable_forever     = true
          target.undestroyable_temporarily = true
          target.save!
        end
      end
      new_parameters[:sections] += [record]
    end
    self.update(new_parameters)
  end

end
