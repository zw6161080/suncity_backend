require 'swagger_helper'

describe 'Appraisal Participator Department API' do

  path '/appraisal_participate_departments' do
    get 'HR index' do
      tags '360评核-详情页（侧栏）'
      parameter name: :appraisal_id, in: :query, type: :integer
      response '200', 'HR获取侧栏列表' do
        schema type: :object,
               properties: {
                   department: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                  { type: :integer },
                               confirmed:           { type: :boolean, description: '未确认 / 已确认' },
                               participator_amount: { type: :integer, description: '数量' },
                               department: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           }
                       }
                   },
                   location: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                  { type: :integer },
                               chinese_name:        { type: :string },
                               english_name:        { type: :string },
                               simple_chinese_name: { type: :string },
                               count:               { type: :integer, description: '数量' }
                           }
                       }
                   },
                   total: {
                       type: :object,
                       properties: {
                           chinese_name:        { type: :string },
                           english_name:        { type: :string },
                           simple_chinese_name: { type: :string },
                           count:               { type: :integer, description: '数量' }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisal_participate_departments/{id}' do
    get '部门主管 show' do
      tags '360评核-详情页（侧栏）'
      parameter name: :id, in: :path, type: :integer
      response '200', 'showed' do
        schema type: :object,
               properties: {
                   department: {
                       type: :object,
                       properties: {
                           id:                  { type: :integer },
                           confirmed:           { type: :boolean, description: '未确认 / 已确认' },
                           participator_amount: { type: :integer, description: '数量' },
                           department: {
                               type: :object,
                               properties: {
                                   id:                  { type: :integer },
                                   chinese_name:        { type: :string },
                                   english_name:        { type: :string },
                                   simple_chinese_name: { type: :string }
                               }
                           }
                       }
                   },
                   location: {
                       type: :object,
                       properties: {
                           id:                  { type: :integer },
                           participator_amount: { type: :integer, description: '数量' },
                           location: {
                               type: :object,
                               properties: {
                                   id:                  { type: :integer },
                                   chinese_name:        { type: :string },
                                   english_name:        { type: :string },
                                   simple_chinese_name: { type: :string }
                               }
                           }
                       }
                   },
                   total: {
                       type: :object,
                       properties: {
                           chinese_name:        { type: :string },
                           english_name:        { type: :string },
                           simple_chinese_name: { type: :string },
                           count:               { type: :integer, description: '数量' }
                       }
                   }
               }
        run_test!
      end
    end

    patch '确认360评核名单' do
      tags '360评核-详情页（侧栏）'
      parameter name: :id, in: :path, type: :integer
      parameter name: :appraisal_participate_department, in: :body, schema: {
          type: :object,
          properties: {
              confirmed: { type: :boolean }
          },
          required: [:confirmed]
      }
      response '200', 'updated' do
        run_test!
      end
    end
  end

end