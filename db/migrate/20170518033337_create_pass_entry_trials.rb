class CreatePassEntryTrials < ActiveRecord::Migration[5.0]
  def change
    create_table :pass_entry_trials do |t|
      t.string :region
      t.integer :user_id
      t.date :apply_date

      t.integer :creator_id
      t.text :employee_advantage
      t.text :employee_need_to_improve
      t.text :employee_opinion

      t.boolean :result
      t.date :trial_expiration_date

      t.boolean :dismissal
      t.date :last_working_date

      t.text :comment

      t.timestamps
    end
  end
end
