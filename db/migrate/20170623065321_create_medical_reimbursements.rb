class CreateMedicalReimbursements < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_reimbursements do |t|
      t.integer :reimbursement_year
      t.references :user, foreign_key: true, index: true
      t.datetime :apply_date, null: false
      t.references :medical_template, foreign_key: true, index: true
      t.references :medical_item,     foreign_key: true, index: true
      t.string :document_number, null: false
      t.decimal :document_amount,      precision:10, scale:2, null: false
      t.decimal :reimbursement_amount, precision:10, scale:2, null: false
      t.references :tracker, foreign_key: {to_table: :users}, index: true
      t.datetime :track_date

      t.timestamps
    end
  end
end
