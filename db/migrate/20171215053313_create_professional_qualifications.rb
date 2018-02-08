class CreateProfessionalQualifications < ActiveRecord::Migration[5.0]
  def change
    create_table :professional_qualifications do |t|
      t.references :profile, index: true, foreign_key: true
      t.string :professional_certificate
      t.string :orgnaization
      t.datetime :issue_date
      t.timestamps
    end
  end
end
