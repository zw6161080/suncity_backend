class CreateMedicalTemplateSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_template_settings do |t|
      t.jsonb :sections
      t.timestamps
    end
  end
end
