require 'swagger_helper'

describe 'Family Declaration API' do

  path '/profiles/{profile_id}/family_declaration_items' do
    post '创建 family_declaration_items' do
      tags '家庭背景'
      parameter name: :profile_id, in: :path, type: :integer
      parameter name: :params, in: :body, schema:{
          type: :object,
          properties: {
              family_member_id:{ype: :integer},
              relative_relation:{type: :string}
          }

      }
      response '200', 'showed the family_declaration_items' do
        run_test!
      end
    end
  end

  path '/profiles/{profile_id}/family_declaration_items/{id}' do
    patch '修改 family_declaration_items' do
      tags '家庭背景'
      parameter name: :profile_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              family_member_id:{ype: :integer},
              relative_relation:{type: :string}
          }
      }
      response '200', 'updated family_declaration_items' do
        run_test!
      end
    end
  end

  path '/profiles/{profile_id}/family_declaration_items/index_by_user' do
    get '展示family_declaration_items' do
      tags '家庭背景'
      parameter name: :profile_id, in: :path, type: :integer
      response '200', 'index family_declaration_items' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   family_member_id:{type: :integer},
                   relative_relation:{type: :string}
               }
        run_test!
      end

    end
  end

  path '/profiles/{profile_id}/family_declaration_items/{id}' do
    delete 'delete family_declaration_items' do
      tags '家庭背景'
      parameter name: :profile_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete family_declaration_items' do
        run_test!
      end
    end
  end
end