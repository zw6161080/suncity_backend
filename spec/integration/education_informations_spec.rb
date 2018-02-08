require 'swagger_helper'

describe 'Education Information API' do

  path '/education_informations' do
    post '创建 education_information' do
      tags '学历信息'
      parameter name: :params, in: :body, schema:{
          type: :object,
          properties: {
              from_mm_yyyy:{type: :date},
              to_mm_yyyy:{type: :date},
              college_university:{type: :string},
              educational_department:{type: :string},
              graduate_level:{type: :string},
              diploma_degree_attained:{type: :string},
              certificate_issue_date:{type: :date},
              graduated:{type: :boolean},
          }

      }
      response '200', 'showed the education_informations' do
        run_test!
      end
    end
  end

  path '/education_informations/{id}' do
    patch '修改 education_informations' do
      tags '学历信息'
      parameter name: :id, in: :path,type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              from_mm_yyyy:{type: :date},
              to_mm_yyyy:{type: :date},
              college_university:{type: :string},
              educational_department:{type: :string},
              graduate_level:{type: :string},
              diploma_degree_attained:{type: :string},
              certificate_issue_date:{type: :date},
              graduated:{type: :boolean},
          }
      }
      response '200', 'updated education_informations' do
        run_test!
      end
    end
  end

  path '/education_informations/index_by_user' do
    get 'education_informations' do
      tags '学历信息'
      parameter name: :user_id, in: :query, type: :integer
      response '200', 'index education_informations' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   from_mm_yyyy:{type: :date},
                   to_mm_yyyy:{type: :date},
                   college_university:{type: :string},
                   educational_department:{type: :string},
                   graduate_level:{type: :string},
                   diploma_degree_attained:{type: :string},
                   certificate_issue_date:{type: :date},
                   graduated:{type: :boolean},
               }
        run_test!
      end

    end
  end

  path '/education_informations/{id}' do
    delete 'delete education_informations' do
      tags '学历信息'
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete education_informations' do
        run_test!
      end
    end
  end
end