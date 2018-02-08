class CreateAppraisalBasicSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :appraisal_basic_settings do |t|
      t.integer :ratio_superior
      t.integer :ratio_subordinate
      t.integer :ratio_collegue
      t.integer :ratio_self
      t.integer :ratio_others_superior
      t.integer :ratio_others_subordinate
      t.integer :ratio_others_collegue
      t.boolean :questionnaire_submit_once_only
      t.string  :introduction
      t.jsonb   :group_A
      t.jsonb   :group_B
      t.jsonb   :group_C
      t.jsonb   :group_D
      t.jsonb   :group_E

      t.timestamps
    end
  end
end
