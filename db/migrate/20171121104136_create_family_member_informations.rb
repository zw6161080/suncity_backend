class CreateFamilyMemberInformations < ActiveRecord::Migration[5.0]
  def change
    create_table :family_member_informations do |t|
      t.string :family_fathers_name_chinese
      t.string :family_fathers_name_english
      t.string :family_mothers_name_chinese
      t.string :family_mothers_name_english
      t.string :family_partenrs_name_chinese
      t.string :family_partenrs_name_english
      t.string :family_kids_name_chinese
      t.string :family_kids_name_english
      t.string :family_bothers_name_chinese
      t.string :family_bothers_name_english
      t.string :family_sisters_name_chinese
      t.string :family_sisters_name_english
      t.string :user_id

      t.timestamps
    end
  end
end
