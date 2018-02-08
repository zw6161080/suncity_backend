class CreateSpecialAssessments < ActiveRecord::Migration[5.0]
  def change
    create_table :special_assessments do |t|
      t.string :region
      t.integer :user_id
      t.date :apply_date

      t.integer :creator_id
      t.text :employee_advantage
      t.text :employee_need_to_improve
      t.text :employee_opinion

      t.text :comment

      t.timestamps
    end
  end
end
