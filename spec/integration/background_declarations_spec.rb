require 'swagger_helper'

describe 'Background Declaration API' do
  path '/background_declarations/{id}' do
    get 'language_skills' do
      tags '语言能力'
      parameter name: :id, in: :path, type: :integer
      response '200', 'show background_declarations' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   have_any_relatives: {type: :integer},
                   relative_criminal_record: {type: :integer},
                   relative_criminal_record_detail: {type: :string},
                   relative_business_relationship_with_suncity: {type: :integer},
                   relative_business_relationship_with_suncity_detail: {type: :string},

               }
        run_test!
      end

    end
  end
end