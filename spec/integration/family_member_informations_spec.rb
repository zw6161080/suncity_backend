require 'swagger_helper'

describe 'Family Member API' do
  path '/family_member_informations/{id}' do
    get 'family_member_informations' do
      tags '家庭成员信息'
      parameter name: :id, in: :path, type: :integer
      response '200', 'show family_member_informations' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   family_fathers_name_chinese: {type: :string},
                   family_fathers_name_english: {type: :string},
                   family_mothers_name_chinese: {type: :string},
                   family_mothers_name_english: {type: :string},
                   family_partenrs_name_chinese: {type: :string},
                   family_partenrs_name_english: {type: :string},
                   family_kids_name_chinese: {type: :string},
                   family_kids_name_english: {type: :string},
                   family_bothers_name_chinese: {type: :string},
                   family_bothers_name_english: {type: :string},
                   family_sisters_name_chinese: {type: :string},
                   family_sisters_name_english: {type: :string},
               }
        run_test!
      end

    end
  end
end