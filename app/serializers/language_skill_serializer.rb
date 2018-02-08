class LanguageSkillSerializer < ActiveModel::Serializer
  attributes :id, :language_chinese_writing, :language_contanese_speaking, :language_contanese_listening, :language_mandarin_speaking, :language_mandarin_listening, :language_english_speaking, :language_english_listening, :language_english_writing, :language_other_name, :language_other_speaking, :language_other_listening, :language_other_writing, :language_skill, :user_id
end
