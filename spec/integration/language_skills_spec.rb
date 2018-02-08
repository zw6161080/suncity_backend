require 'swagger_helper'

describe 'Language Skill API' do
  path '/language_skills/{id}' do
    get 'language_skills' do
      tags '语言能力'
      parameter name: :id, in: :path, type: :integer
      response '200', 'show language_skills' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   language_chinese_writing: {type: :integer},
                   language_contanese_speaking: {type: :integer},
                   language_contanese_listening: {type: :integer},
                   language_mandarin_speaking: {type: :integer},
                   language_mandarin_listening: {type: :integer},
                   language_english_speaking: {type: :integer},
                   language_english_listening: {type: :integer},
                   language_english_writing: {type: :integer},
                   language_other_name: {type: :string},
                   language_other_speaking: {type: :integer},
                   language_other_listening: {type: :integer},
                   language_other_writing: {type: :integer},
                   language_skill: {type: :string},
               }
        run_test!
      end

    end
  end
end