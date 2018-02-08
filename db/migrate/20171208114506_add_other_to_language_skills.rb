class AddOtherToLanguageSkills < ActiveRecord::Migration[5.0]
  def change
    add_column :language_skills, :language_skill, :string
  end
end
