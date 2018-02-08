class CreateAppraisalDepartmentSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_department_settings do |t|

      t.references :location, foreign_key: true
      t.references :department, foreign_key: true
      t.references :appraisal_basic_setting, foreign_key: true, index: { :name => 'idnex_appraisal_department_setting_on_basic' }
      t.boolean    :can_across_appraisal_grade
      t.string     :appraisal_mode_superior
      t.integer    :appraisal_times_superior
      t.string     :appraisal_mode_collegue
      t.integer    :appraisal_times_collegue
      t.string     :appraisal_mode_subordinate
      t.integer    :appraisal_times_subordinate
      t.integer    :appraisal_grade_quantity_inside
      t.boolean    :whether_group_inside

      t.timestamps
    end

    add_reference :appraisal_department_settings, :group_A_appraisal_template, index: { :name => 'index_appraisal_department_setting_on_group_A'}
    add_foreign_key :appraisal_department_settings, :questionnaire_templates, column: :group_A_appraisal_template_id

    add_reference :appraisal_department_settings, :group_B_appraisal_template, index: { :name => 'index_appraisal_department_setting_on_group_B'}
    add_foreign_key :appraisal_department_settings, :questionnaire_templates, column: :group_B_appraisal_template_id

    add_reference :appraisal_department_settings, :group_C_appraisal_template, index: { :name => 'index_appraisal_department_setting_on_group_C'}
    add_foreign_key :appraisal_department_settings, :questionnaire_templates, column: :group_C_appraisal_template_id

    add_reference :appraisal_department_settings, :group_D_appraisal_template, index: { :name => 'index_appraisal_department_setting_on_group_D'}
    add_foreign_key :appraisal_department_settings, :questionnaire_templates, column: :group_D_appraisal_template_id

    add_reference :appraisal_department_settings, :group_E_appraisal_template, index: { :name => 'index_appraisal_department_setting_on_group_E'}
    add_foreign_key :appraisal_department_settings, :questionnaire_templates, column: :group_E_appraisal_template_id
  end
end
