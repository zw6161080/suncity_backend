require 'swagger_helper'

describe 'Social Security Fund API' do

  path '/social_security_fund_items' do
    get '获取社会保障数据列表' do
      tags '社会保障金'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :year_month, type: :string, in: :query, description: '筛选年月，格式：YYYY/MM'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            user_id: { type: :integer },
            year_month: { type: :date },
            employee_payment_mop: { type: :string },
            company_payment_mop: { type: :string },
            career_entry_date: { type: :date },
            employee_type: { type: :string },
            user: { '$ref' => '#/definitions/user' }
          }
        }
        run_test!
      end

    end
  end

  path '/social_security_fund_items/year_month_options' do
    get '获取年月下拉选项' do
      tags '社会保障金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { type: :string }
        run_test!
      end
    end
  end

  path '/social_security_fund_items/columns' do
    get '获取社会保障金报表的列' do
      tags '社会保障金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { '$ref' => '#/definitions/statement_column' }
        run_test!
      end
    end
  end

  path '/social_security_fund_items/options' do
    get '获取社会保障金下拉选项' do
      tags '社会保障金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

end