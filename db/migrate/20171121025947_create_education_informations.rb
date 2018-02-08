class CreateEducationInformations < ActiveRecord::Migration[5.0]
  def change
    create_table :education_informations do |t|
      t.date :from_mm_yyyy
      t.date :to_mm_yyyy
      t.string :college_university
      t.string :educational_department
      t.string :graduate_level
      t.string :diploma_degree_attained
      t.date :certificate_issue_date
      t.boolean :graduated

      t.timestamps
    end
  end
end
