class CreateTrainingAbsentees < ActiveRecord::Migration[5.0]
  def change
    create_table :training_absentees do |t|
      t.references :user, foreign_key: true, index: true
      t.references :train_class, foreign_key: true, index: true
      t.boolean    :has_submitted_reason
      t.boolean    :has_been_exempted
      t.string     :absence_reason
      t.datetime   :submit_date

      t.timestamps
    end
  end
end
