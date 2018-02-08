class CreateRevisionHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :revision_histories do |t|
      t.references :appraisal_questionnaire, index: true, foreign_key: true
      t.references :user, foreign_key: true
      t.text       :content
      t.datetime   :revision_date
      t.timestamps
    end
  end
end
