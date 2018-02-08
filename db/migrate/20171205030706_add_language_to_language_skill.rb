class AddLanguageToLanguageSkill < ActiveRecord::Migration[5.0]
  def change
    add_column :language_skills, :language_chinese_writing, :string
    add_column :language_skills, :language_contanese_speaking, :string
    add_column :language_skills, :language_contanese_listening, :string
    add_column :language_skills, :language_mandarin_speaking, :string
    add_column :language_skills, :language_mandarin_listening, :string
    add_column :language_skills, :language_english_speaking, :string
    add_column :language_skills, :language_english_listening, :string
    add_column :language_skills, :language_english_writing, :string
    add_column :language_skills, :language_other_speaking, :string
    add_column :language_skills, :language_other_listening, :string
    add_column :language_skills, :language_other_writing, :string
  end
end
