# == Schema Information
#
# Table name: language_skills
#
#  id                           :integer          not null, primary key
#  language_other_name          :string
#  user_id                      :integer
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  language_chinese_writing     :string
#  language_contanese_speaking  :string
#  language_contanese_listening :string
#  language_mandarin_speaking   :string
#  language_mandarin_listening  :string
#  language_english_speaking    :string
#  language_english_listening   :string
#  language_english_writing     :string
#  language_other_speaking      :string
#  language_other_listening     :string
#  language_other_writing       :string
#  language_skill               :string
#
# Indexes
#
#  index_language_skills_on_user_id  (user_id)
#

class LanguageSkill < ApplicationRecord
  validates :language_chinese_writing, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_contanese_speaking, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_contanese_listening, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_mandarin_speaking, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_mandarin_listening, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_english_speaking, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_english_listening, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_english_writing, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_other_speaking, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_other_listening, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  validates :language_other_writing, inclusion: {in: [ 'excellent', 'good', 'fair', nil ]}
  belongs_to :user

end
