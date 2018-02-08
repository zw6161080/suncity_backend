class CreateMedicalInsuranceParticipators < ActiveRecord::Migration[5.0]
  def change
    create_table :medical_insurance_participators do |t|
      t.references :user, foreign_key: true, index: true
      t.string     :participate, index: true
      t.datetime   :participate_date, index: true
      t.datetime   :cancel_date, index: true
      t.references :medical_template, foreign_key: true, index: true
      t.decimal    :monthly_deduction, precision:10, scale:2

      t.timestamps
    end
  end
end
