class ChangeReferenceToAssessRelationships < ActiveRecord::Migration[5.0]
  def change
    remove_reference :assess_relationships, :assess_participator, index: true
    # remove_foreign_key :assess_relationships, :appraisal_participators, column: :assess_participator_id

    add_reference :assess_relationships, :assessor, index: true
    add_foreign_key :assess_relationships, :users, column: :assessor_id
  end
end
