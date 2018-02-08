class CreateMedicalTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_templates do |t|
      t.string   :chinese_name,        index: true, null: false
      t.string   :english_name,        index: true, null: false
      t.string   :simple_chinese_name, index: true, null: false
      t.string   :insurance_type,      index: true, null: false
      t.datetime :balance_date,        index: true, null: false

      t.timestamps
    end

    create_table :medical_items_templates, id: false do |t|
      t.belongs_to :medical_template, index: true
      t.belongs_to :medical_item, index: true
    end
  end
end
