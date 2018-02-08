class CreateMedicalItems < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_items do |t|
      t.string  :chinese_name,        index: true, null: false
      t.string  :english_name,        index: true, null: false
      t.string  :simple_chinese_name, index: true, null: false
      t.integer :reimbursement_times,        index: true
      t.decimal :reimbursement_amount_limit, index: true, precision:10, scale:2
      t.decimal :reimbursement_amount,       index: true, precision:10, scale:2
      t.boolean :can_be_delete

      t.timestamps
    end
  end
end
