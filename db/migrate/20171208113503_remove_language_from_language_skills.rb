class RemoveLanguageFromLanguageSkills < ActiveRecord::Migration[5.0]
  def change
    remove_column :language_skills, :language_skill, :string
  end
end
