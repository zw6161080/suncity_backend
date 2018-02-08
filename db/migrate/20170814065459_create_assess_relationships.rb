class CreateAssessRelationships < ActiveRecord::Migration[5.0]
  def change
    create_table :assess_relationships do |t|

      t.string :assess_type
      t.references :appraisal, foreign_key: true, index: true
      t.references :appraisal_participator, index: true, foregin_key: true
      t.timestamps
    end

    add_reference :assess_relationships, :assess_participator, index: true
    add_foreign_key :assess_relationships, :appraisal_participators, column: :assess_participator_id

  end
end
