class AddSignalsToMedicalTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :medical_templates, :undestroyable_forever, :boolean
    add_column :medical_templates, :undestroyable_temporarily, :boolean
  end
end
