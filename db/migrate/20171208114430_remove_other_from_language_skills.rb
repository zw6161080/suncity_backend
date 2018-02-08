class RemoveOtherFromLanguageSkills < ActiveRecord::Migration[5.0]
  def change
    remove_column :language_skills, :other_skill, :string
  end
end
