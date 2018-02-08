class CreateCandidateRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :candidate_relationships do |t|
      t.string :assess_type
      t.references :appraisal, foreign_key: true, index: true
      t.references :appraisal_participator, index: true, foregin_key: true
      t.timestamps
    end

    add_reference :candidate_relationships, :candidate_participator, index: true
    add_foreign_key :candidate_relationships, :appraisal_participators, column: :candidate_participator_id

  end
end
