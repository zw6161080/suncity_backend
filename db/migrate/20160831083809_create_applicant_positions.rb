class CreateApplicantPositions < ActiveRecord::Migration[5.0]
  def change
    create_table :applicant_positions do |t|
      t.belongs_to :department
      t.belongs_to :position
      t.belongs_to :applicant_profile
      
      t.timestamps
    end
  end
end
