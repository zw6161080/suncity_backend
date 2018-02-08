class CreateApplicantSelectColumnTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :applicant_select_column_templates do |t|
      t.string :name, unique: true
      t.jsonb :select_column_keys
      t.boolean :default, default: false, index: true
      t.string :region
      t.timestamps
    end
  end
end
