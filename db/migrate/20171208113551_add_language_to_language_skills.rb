class AddLanguageToLanguageSkills < ActiveRecord::Migration[5.0]
  def change
    add_column :language_skills, :other_skill, :string
  end
end
