class CreateAssistantProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :assistant_profiles do |t|
      t.integer :profile_id
      t.integer :paid_sick_leave_award_id
      t.string  :date_of_employment
      t.integer :days_in_office
      t.integer :has_used_days
      t.integer :days_of_award
      t.timestamps
    end
  end
end
