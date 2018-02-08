class CreateAssistantProfileToAnnualWorkAwards < ActiveRecord::Migration[5.0]
  def change
    create_table :assistant_profile_to_annual_work_awards do |t|
      t.integer :profile_id
      t.integer :annual_work_award_id
      t.string  :date_of_employment
      t.integer :up_to_standard
      t.integer :money_of_award
      t.timestamps
    end
  end
end
