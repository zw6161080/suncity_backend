require 'swagger_helper'

describe 'Payroll Report API' do

  path '/payroll_reports' do

    get '获取工资月表列表' do
      tags '工资表'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object, properties: {
            id: { type: :integer },
            year_month: { type: :string },
            granted: { type: :boolean },
            status: { type: :string, enum: %w(initial processing finished) }
          }
        }

        run_test!
      end
    end

    post '创建工资月表' do
      tags '工资表'
      consumes 'application/json'
      produces 'application/json'

      response '201', '创建成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          year_month: { type: :string },
          granted: { type: :boolean },
          status: { type: :string, enum: %w(initial processing finished) }
        }

        run_test!
      end
    end
  end

  path '/payroll_reports/{id}' do

    get '获取某个工资月表' do
      tags '工资表'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '工资月表的ID'

      response '200', '获取成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          year_month: { type: :string },
          granted: { type: :boolean },
          status: { type: :string, enum: %w(initial processing finished) }
        }

        run_test!
      end
    end

    delete '删除某个工资月表' do
      tags '工资表'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '工资月表的ID'

      response '204', '删除成功' do
        run_test!
      end
    end
  end

  path '/payroll_reports/{id}/setup' do
    patch '开始生成工资表数据' do
      tags '工资表'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '工资月表的ID'

      response '201', '请求成功' do
        run_test!
      end
    end
  end

  path '/payroll_reports/{id}/grant' do
    patch '审批工资月表' do
      tags '工资表'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '工资月表的ID'

      response '201', '请求成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          year_month: { type: :string },
          granted: { type: :boolean },
          status: { type: :string, enum: %w(initial processing finished) }
        }

        run_test!
      end
    end

  end

end