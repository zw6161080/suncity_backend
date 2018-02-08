class AddCanbedeleteToMedicalTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :medical_templates, :can_be_delete, :boolean
  end
end
