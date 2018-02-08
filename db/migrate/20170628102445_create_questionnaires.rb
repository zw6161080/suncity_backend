class CreateQuestionnaires < ActiveRecord::Migration[5.0]
  def change
    create_table :questionnaires do |t|
      t.string :region
      t.integer :questionnaire_template_id

      t.integer :user_id
      t.boolean :is_filled_in
      t.date :release_date
      t.integer :release_user_id
      t.date :submit_date

      t.text :comment
      t.timestamps
    end
  end
end
