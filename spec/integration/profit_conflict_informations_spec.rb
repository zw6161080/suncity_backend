require 'swagger_helper'

describe 'Profile Conflict API' do

  path '/profile_conflict_informations/{id}' do
    patch '修改 profile_conflict_informations' do
      tags '利益冲突'
      parameter name: :id, in: :path,type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              have_or_no:{type: :boolean},
              number:{type: :string}
          }
      }
      response '200', 'updated profile_conflict_informations' do
        run_test!
      end
    end
  end

  path '/profile_conflict_informations/{id}' do
    delete 'delete profile_conflict_informations' do
      tags '利益冲突'
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete profile_conflict_informations' do
        run_test!
      end
    end
  end
end