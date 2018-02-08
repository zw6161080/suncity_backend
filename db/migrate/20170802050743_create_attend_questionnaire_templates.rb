class CreateAttendQuestionnaireTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_questionnaire_templates do |t|
      t.integer :questionnaire_template_id
      t.integer :attachable_id
      t.string  :attachable_type
      t.index :questionnaire_template_id, name: 'index_a_q_t_on_q_t'
    end
    add_index :attend_questionnaire_templates, [:attachable_id, :attachable_type],
              name: "a_q_t"
  end
end
