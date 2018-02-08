class CreateLanguageSkills < ActiveRecord::Migration[5.0]
  def change
    create_table :language_skills do |t|
      t.integer :language_chinese_writing
      t.integer :language_contanese_speaking
      t.integer :language_contanese_listening
      t.integer :language_mandarin_speaking
      t.integer :language_mandarin_listening
      t.integer :language_english_speaking
      t.integer :language_english_listening
      t.integer :language_english_writing
      t.string :language_other_name
      t.integer :language_other_speaking
      t.integer :language_other_listening
      t.integer :language_other_writing
      t.string :language_skill
      t.integer :user_id

      t.timestamps
    end
  end
end
