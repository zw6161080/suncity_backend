class DeleteLanguageFromLanguageSkill < ActiveRecord::Migration[5.0]
  def change
    remove_column :language_skills, :language_chinese_writing, :integer
    remove_column :language_skills, :language_contanese_speaking, :integer
    remove_column :language_skills, :language_contanese_listening, :integer
    remove_column :language_skills, :language_mandarin_speaking, :integer
    remove_column :language_skills, :language_mandarin_listening, :integer
    remove_column :language_skills, :language_english_speaking, :integer
    remove_column :language_skills, :language_english_listening, :integer
    remove_column :language_skills, :language_english_writing, :integer
    remove_column :language_skills, :language_other_speaking, :integer
    remove_column :language_skills, :language_other_listening, :integer
    remove_column :language_skills, :language_other_writing, :integer
  end
end
