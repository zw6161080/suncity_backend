class CreateAgreementFiles < ActiveRecord::Migration[5.0]
  def change
    create_table :agreement_files do |t|
      t.belongs_to :agreement
      t.belongs_to :applicant_position
      t.belongs_to :attachment
      t.integer :creater_id

      t.timestamps
    end
  end
end
