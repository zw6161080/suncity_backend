require 'swagger_helper'

describe 'Contract Information API' do

  path '/profiles/{profile_id}/contract_informations' do
    post '创建 contract_informations' do
      tags '合同信息'
      parameter name: :profile_id, in: :path,type: :integer
      parameter name: :params, in: :body, schema:{
          type: :object,
          properties: {
              contract_information_type_id: {type: :integer},
              attachment_id: {type: :integer},
              description: {type: :string},
              creator_id: {type: :integer},
              file_name: {type: :string}
          }

      }
      response '200', 'showed the contract_informations' do
        run_test!
      end
    end
  end

  path '/profiles/{profile_id}/contract_informations/{id}/download' do
    get '下载附件' do
      tags '合同信息'
      parameter name: :id, in: :path, type: :integer
      parameter name: :profile_id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              attachment_id: {type: :integer},
              file_name: {type: :string}
          }
      }
      response '200', 'download the contract_informations' do
        run_test!
      end
    end
  end

  path '/profiles/{profile_id}/contract_informations/{id}/preview' do
    get '展示附件' do
      tags '合同信息'
      parameter name: :id, in: :path, type: :integer
      parameter name: :profile_id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              attachment_id: {type: :integer},
              file_name: {type: :string}
          }
      }
      response '200', 'download the contract_informations' do
        run_test!
      end
    end
  end

  path '/profiles/{profile_id}/contract_informations/{id}' do
    patch '修改 contract_informations' do
      tags '合同信息'
      parameter name: :id, in: :path,type: :integer
      parameter name: :profile_id, in: :path,type: :integer

      response '200', 'updated contract_informations' do
        schema type: :object,
            properties: {
                attachment_id: {type: :integer},
                file_name: {type: :string}
            }
        run_test!
      end
    end
  end

  path '/profiles/{profile_id}/contract_informations' do
    get '展示 contract_informations' do
      tags '合同信息'
      parameter name: :profile_id, in: :path, type: :integer
      response '200', 'index contract_informations' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   contract_information_type_id: {type: :integer},
                   attachment_id: {type: :integer},
                   description: {type: :string},
                   creator_id: {type: :integer},
                   file_name: {type: :string}
               }
        run_test!
      end

    end
  end

  path '/profiles/{profile_id}/contract_informations/{id}' do
    delete 'delete contract_informations' do
      tags '合同信息'
      parameter name: :id, in: :path, type: :integer
      parameter name: :profile_id, in: :path,type: :integer
      response '200', 'delete contract_informations' do
        run_test!
      end
    end
  end
end