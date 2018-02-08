# == Schema Information
#
# Table name: appraisal_department_settings
#
#  id                              :integer          not null, primary key
#  location_id                     :integer
#  department_id                   :integer
#  appraisal_basic_setting_id      :integer
#  can_across_appraisal_grade      :boolean
#  appraisal_mode_superior         :string
#  appraisal_times_superior        :integer
#  appraisal_mode_collegue         :string
#  appraisal_times_collegue        :integer
#  appraisal_mode_subordinate      :string
#  appraisal_times_subordinate     :integer
#  appraisal_grade_quantity_inside :integer
#  whether_group_inside            :boolean
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  group_A_appraisal_template_id   :integer
#  group_B_appraisal_template_id   :integer
#  group_C_appraisal_template_id   :integer
#  group_D_appraisal_template_id   :integer
#  group_E_appraisal_template_id   :integer
#
# Indexes
#
#  idnex_appraisal_department_setting_on_basic           (appraisal_basic_setting_id)
#  index_appraisal_department_setting_on_group_A         (group_A_appraisal_template_id)
#  index_appraisal_department_setting_on_group_B         (group_B_appraisal_template_id)
#  index_appraisal_department_setting_on_group_C         (group_C_appraisal_template_id)
#  index_appraisal_department_setting_on_group_D         (group_D_appraisal_template_id)
#  index_appraisal_department_setting_on_group_E         (group_E_appraisal_template_id)
#  index_appraisal_department_settings_on_department_id  (department_id)
#  index_appraisal_department_settings_on_location_id    (location_id)
#
# Foreign Keys
#
#  fk_rails_1347df5d27  (group_A_appraisal_template_id => questionnaire_templates.id)
#  fk_rails_1b33876589  (department_id => departments.id)
#  fk_rails_68dacc8995  (group_C_appraisal_template_id => questionnaire_templates.id)
#  fk_rails_6f0690e610  (group_E_appraisal_template_id => questionnaire_templates.id)
#  fk_rails_853192e913  (group_B_appraisal_template_id => questionnaire_templates.id)
#  fk_rails_9f52bf953a  (location_id => locations.id)
#  fk_rails_de06ad49ca  (appraisal_basic_setting_id => appraisal_basic_settings.id)
#  fk_rails_ed9dfcb4d9  (group_D_appraisal_template_id => questionnaire_templates.id)
#

class AppraisalDepartmentSetting < ApplicationRecord

  has_many :appraisal_participator
  belongs_to :location
  belongs_to :department
  belongs_to :appraisal_basic_setting
  has_many   :appraisal_groups, dependent: :destroy
  has_many   :appraisal_employee_settings

  def self.whether_appraisal_template_has_been_setted(params)
    effective_groups = AppraisalBasicSetting.effective_groups
    department_settings = AppraisalDepartmentSetting.where(location_id: params[:location]).where(department_id: params[:department])
    effective_groups.each do |group_no|
      return false if department_settings.where("group_#{group_no}_appraisal_template_id": nil).size > 0
    end
    return true
  end

  def group_to_questionnaire_template_id(group)
    self["group_#{group}_appraisal_template_id"]
  end

  def self.batch_update(location_ids, params)
    ActiveRecord::Base.transaction do
      AppraisalDepartmentSetting.where(location_id: location_ids).each do |record|
        record.update(params)
      end
    end
  end

  def self.create_department_setting
    initial_setting = Config.get('appraisal_department_setting')['department_setting']
    ActiveRecord::Base.transaction do
      Location.model_with_departments.each do |location|
        location.departments.each do |department|
          unless self.find_by(location_id: location.id, department_id: department.id)
            self.create(department_id: department.id, location_id: location.id) do |setting|
              setting.appraisal_basic_setting_id = AppraisalBasicSetting.all.first.id
              initial_setting.each do |key, initialValue|
                setting[key] = initialValue
              end
              setting.save!
            end
          end
        end
      end
    end
  end

  def self.create_all_related_settings
    initial_setting = Config.get('appraisal_department_setting')['department_setting']
    ActiveRecord::Base.transaction do
      Location.model_with_departments.each do |location|
        location.departments.each do |department|
          self.find_or_create_by(
            department_id: department.id,
            location_id: location.id
          ) do |setting|
            setting.appraisal_basic_setting_id = AppraisalBasicSetting.all.first.id
            initial_setting.each do |key, initialValue|
              setting[key] = initialValue
            end
            setting.save!
          end
        end
      end
    end
  end
end
