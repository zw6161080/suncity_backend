require 'swagger_helper'

describe 'Contract Information Type API' do

  path '/contract_information_types' do
    post '创建 contract_information_types' do
      tags '合同信息类型'
      parameter name: :params, in: :body, schema:{
          type: :object,
          properties: {
              chinese_name: {type: :string},
              english_name: {type: :string},
              description: {type: :string}
          }

      }
      response '200', 'showed the contract_information_types' do
        run_test!
      end
    end
  end

  path '/contract_information_types/{id}' do
    patch '修改 contract_information_types' do
      tags '合同信息类型'
      parameter name: :id, in: :path,type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              chinese_name: {type: :string},
              english_name: {type: :string},
              description: {type: :string}
          }
      }
      response '200', 'updated contract_information_types' do
        run_test!
      end
    end
  end

  path '/contract_information_types' do
    get '展示 contract_information_types' do
      tags '合同信息类型'
      response '200', 'index contract_information_types' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   chinese_name: {type: :string},
                   english_name: {type: :string},
                   description: {type: :string}
               }
        run_test!
      end

    end
  end

  path '/contract_information_types/{id}' do
    delete 'delete contract_information_types' do
      tags '合同信息类型'
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete contract_information_types' do
        run_test!
      end
    end
  end
end