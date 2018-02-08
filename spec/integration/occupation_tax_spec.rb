require 'swagger_helper'

describe 'Occupation Tax API' do

  path '/occupation_tax_settings' do
    get '获取职业税税率设置数值' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :object, properties: {
          id: { type: :integer },
          deduct_percent: { type: :string },
          favorable_percent: { type: :string },
          ranges: {
            type: :array, items: {
              type: :object,
              properties: {
                limit: { type: :string },
                tax_rate: { type: :string }
              }
            }
          }
        }
        run_test!
      end
    end

    patch '更新职业税税率设置数值' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :occupation_tax_setting, in: :body, schema: {
        type: :object,
        properties: {
          deduct_percent: { type: :string },
          favorable_percent: { type: :string },
          ranges: {
            type: :array, items: {
              type: :object,
              properties: {
                limit: { type: :string },
                tax_rate: { type: :string }
              }
            }
          }
        }
      }

      response '200', '请求成功' do
        run_test!
      end
    end
  end

  path '/occupation_tax_settings/reset' do
    patch '重置职业税税率数值' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

  path '/occupation_tax_items' do
    get '获取职业税条目数据' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            user_id: { type: :integer },
            year: { type: :date },
            month_1_company: { type: :string },
            month_1_income_mop: { type: :string },
            month_1_tax_mop: { type: :string },
            month_2_company: { type: :string },
            month_2_income_mop: { type: :string },
            month_2_tax_mop: { type: :string },
            month_3_company: { type: :string },
            month_3_income_mop: { type: :string },
            month_3_tax_mop: { type: :string },
            quarter_1_income_mop: { type: :string },
            quarter_1_tax_mop_before_adjust: { type: :string },
            quarter_1_tax_mop_after_adjust: { type: :string },
            month_4_company: { type: :string },
            month_4_income_mop: { type: :string },
            month_4_tax_mop: { type: :string },
            month_5_company: { type: :string },
            month_5_income_mop: { type: :string },
            month_5_tax_mop: { type: :string },
            month_6_company: { type: :string },
            month_6_income_mop: { type: :string },
            month_6_tax_mop: { type: :string },
            quarter_2_income_mop: { type: :string },
            quarter_2_tax_mop_before_adjust: { type: :string },
            quarter_2_tax_mop_after_adjust: { type: :string },
            month_7_company: { type: :string },
            month_7_income_mop: { type: :string },
            month_7_tax_mop: { type: :string },
            month_8_company: { type: :string },
            month_8_income_mop: { type: :string },
            month_8_tax_mop: { type: :string },
            month_9_company: { type: :string },
            month_9_income_mop: { type: :string },
            month_9_tax_mop: { type: :string },
            quarter_3_income_mop: { type: :string },
            quarter_3_tax_mop_before_adjust: { type: :string },
            quarter_3_tax_mop_after_adjust: { type: :string },
            month_10_company: { type: :string },
            month_10_income_mop: { type: :string },
            month_10_tax_mop: { type: :string },
            month_11_company: { type: :string },
            month_11_income_mop: { type: :string },
            month_11_tax_mop: { type: :string },
            month_12_company: { type: :string },
            month_12_income_mop: { type: :string },
            month_12_tax_mop: { type: :string },
            quarter_4_income_mop: { type: :string },
            quarter_4_tax_mop_before_adjust: { type: :string },
            year_income_mop: { type: :string },
            year_payable_tax_mop: { type: :string },
            year_paid_tax_mop: { type: :string },
            quarter_4_tax_mop_after_adjust: { type: :string },
            comment: { type: :string },
            user: { '$ref' => '#/definitions/user' }
          }
        }

        run_test!
      end
    end
  end

  path '/occupation_tax_items/columns' do
    get '获取职业税报表列' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { '$ref' => '#/definitions/statement_column' }
        run_test!
      end
    end
  end

  path '/occupation_tax_items/options' do
    get '获取职业税报表下拉选项' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

  path '/occupation_tax_items/year_options' do
    get '获取年份筛选项' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { type: :string }
        run_test!
      end
    end
  end

  path '/occupation_tax_items/{id}' do
    patch '更新备注' do
      tags '职业税'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, description: '职业税条目的ID'
      parameter name: :comment, in: :body, type: :string, description: '备注'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

end