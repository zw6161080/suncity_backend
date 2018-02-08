require 'swagger_helper'

describe 'select column template API' do
  path '/select_column_templates/create_by_department' do
    post '创建 select_column_templates' do
      tags '部门员工档案创建模板'
      parameter name: :params, in: :body, schema:{
          type: :object,
          properties: {
              name:{type: :string},
              select_column_keys:{type: :string},
              default:{type: :boolean},
              region:{type: :string},
              department_id:{type: :integer}
          }

      }
      response '200', 'create the select_column_templates' do
        run_test!
      end
    end
  end

  path '/select_column_templates/index_by_department' do
    get '展示 select_column_templates' do
      tags '部门员工档案创建模板'
      parameter name: :department_id, in: :query, type: :integer
      response '200', 'index select_column_templates' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   name:{type: :string},
                   select_column_keys:{type: :string},
                   default:{type: :boolean},
                   region:{type: :string},
                   department_id:{type: :integer}
               }
        run_test!
      end

    end
  end
end