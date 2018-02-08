require 'swagger_helper'

describe 'Salary Element API' do

  path '/salary_element_categories' do
    get '获取薪金计算项类别以及其包含的所有薪金计算项以及参数' do
      tags '薪金计算项设置'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer, description: '薪金计算项类别ID' },
            chinese_name: { type: :string, description: '薪金计算项目类别繁体中文名' },
            english_name: { type: :string, description: '薪金计算项目类别英文名' },
            simple_chinese_name: { type: :string, description: '薪金计算项目类别简体中文名' },
            key: { type: :string, description: '薪金计算项类别的KEY' },
            salary_elements: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer, description: '薪金计算项的ID' },
                  chinese_name: { type: :string, description: '薪金计算项的繁体中文名' },
                  english_name: { type: :string, description: '薪金计算项的英文名' },
                  simple_chinese_name: { type: :string, description: '薪金计算项的简体中文名' },
                  key: { type: :string, description: '薪金计算项的KEY' },
                  salary_element_category_id: { type: :integer, description: '薪金计算项所属的类别的ID' },
                  display_template: { type: :string, description: '薪金计算项公式的显示字符串' },
                  comment: { type: :string, description: '薪金计算项目公式的备注' },
                  salary_element_factors: {
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        id: { type: :integer, description:' 薪金计算项参数的ID' },
                        chinese_name: { type: :string, description: '薪金计算参数繁体中文名' },
                        english_name: { type: :string, description: '薪金计算参数英文名' },
                        simple_chinese_name: { type: :string, description: '薪金计算参数简体中文名' },
                        key: { type: :string, description: '薪金计算参数的KEY' },
                        salary_element_id: { type: :integer, description: '薪金计算参数所属的薪金项的ID' },
                        factor_type: { type: :string, enum: [ 'fraction', 'value' ] },
                        numerator: { type: :string, description: '分子' },
                        denominator: { type: :string, description: '分母' },
                        value: { type: :string, description: '值' },
                        comment: { type: :string, description: '备注' }
                      }
                    }
                  }
                }
              }
            }
          }
        }
        run_test!
      end
    end
  end

  path '/salary_element_categories/{id}' do
    get '获取某一个薪金计算项类别以及其包含的所有薪金计算项以及参数' do
      tags '薪金计算项设置'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :object, properties: {
          id: { type: :integer, description: '薪金计算项类别ID' },
          chinese_name: { type: :string, description: '薪金计算项目类别繁体中文名' },
          english_name: { type: :string, description: '薪金计算项目类别英文名' },
          simple_chinese_name: { type: :string, description: '薪金计算项目类别简体中文名' },
          key: { type: :string, description: '薪金计算项类别的KEY' },
          salary_elements: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer, description: '薪金计算项的ID' },
                chinese_name: { type: :string, description: '薪金计算项的繁体中文名' },
                english_name: { type: :string, description: '薪金计算项的英文名' },
                simple_chinese_name: { type: :string, description: '薪金计算项的简体中文名' },
                key: { type: :string, description: '薪金计算项的KEY' },
                salary_element_category_id: { type: :integer, description: '薪金计算项所属的类别的ID' },
                display_template: { type: :string, description: '薪金计算项公式的显示字符串' },
                comment: { type: :string, description: '薪金计算项目公式的备注' },
                salary_element_factors: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :integer, description:' 薪金计算项参数的ID' },
                      chinese_name: { type: :string, description: '薪金计算参数繁体中文名' },
                      english_name: { type: :string, description: '薪金计算参数英文名' },
                      simple_chinese_name: { type: :string, description: '薪金计算参数简体中文名' },
                      key: { type: :string, description: '薪金计算参数的KEY' },
                      salary_element_id: { type: :integer, description: '薪金计算参数所属的薪金项的ID' },
                      factor_type: { type: :string, enum: [ 'fraction', 'value' ] },
                      numerator: { type: :string, description: '分子' },
                      denominator: { type: :string, description: '分母' },
                      value: { type: :string, description: '值' },
                      comment: { type: :string, description: '备注' }
                    }
                  }
                }
              }
            }
          }
        }
        run_test!
      end
    end
  end

  path '/salary_element_categories/reset' do
    patch '重置薪金计算规则' do
      tags '薪金计算项设置'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

  path '/salary_element_factors/batch_update' do
    patch '批量更新薪金计算项参数' do
      tags '薪金计算项设置'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :updates, in: :body, schema: {
        type: :array,
        items: {
          type: :object,
          properties: {
            numerator: { type: :string },
            denominator: { type: :string },
            value: { type: :string }
          }
        }
      }

      response '200', '请求成功' do
        run_test!
      end
    end
  end

end