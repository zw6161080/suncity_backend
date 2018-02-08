class CreateApplicantProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :applicant_profiles do |t|
      #求职者编号
      t.string :applicant_no
      t.string :chinese_name
      t.string :english_name
      t.string :id_card_number

      t.string :region
      t.jsonb :data

      t.timestamps
    end

    add_index :applicant_profiles, :applicant_no
    add_index :applicant_profiles, :chinese_name
    add_index :applicant_profiles, :english_name
    add_index :applicant_profiles, :id_card_number
    add_index :applicant_profiles, :region
  end
end
