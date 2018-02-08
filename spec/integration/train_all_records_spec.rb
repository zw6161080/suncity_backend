require 'swagger_helper'

describe 'Trains All Records API' do

  path '/trains/all_records.json' do
    get 'Index 培訓記錄-全部記錄' do
      tags '培訓記錄-全部記錄'
      parameter name: :locale,           in: :query, type: :string, description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :empoid,           in: :query, type: :string, description: '員工編號'
      parameter name: :name,             in: :query, type: :string, description: '員工姓名'
      parameter name: :department,       in: :query, type: :string, description: '部門'
      parameter name: :position,         in: :query, type: :string, description: '職位'
      parameter name: :train_name,       in: :query, type: :string, description: '培訓名稱'
      parameter name: :train_number,     in: :query, type: :string, description: '培訓編號'
      parameter name: :date_of_train,    in: :query, type: :string, description: '培訓日期'
      parameter name: :train_type,       in: :query, type: :string, description: '培訓種類'
      parameter name: :train_cost,       in: :query, type: :string, description: '培訓費用'
      parameter name: :attendance_rate,  in: :query, type: :string, description: '出席率'
      parameter name: :train_result,     in: :query, type: :boolean, description: '培訓結果'

      response '200', 'all_records found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               empoid: { type: :string },
                               chinese_name: { type: :string },
                               english_name: { type: :string },
                               simple_chinese_name: { type: :string },
                               department_chinese_name: { type: :string },
                               department_english_name: { type: :string },
                               department_simple_chinese_name: { type: :string },
                               position_chinese_name: { type: :string },
                               position_english_name: { type: :string },
                               position_simple_chinese_name: { type: :string },
                               train_result: { type: :boolean },
                               attendance_rate: { type: :string },
                               train: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
                                       train_date_begin: { type: :string },
                                       train_date_end: { type: :string },
                                       train_cost: { type: :string },
                                       train_number: { type: :string },
                                       train_template: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               train_template_type: {
                                                   type: :object,
                                                   properties: {
                                                       id: { type: :integer },
                                                       chinese_name: { type: :string },
                                                       english_name: { type: :string },
                                                       simple_chinese_name: { type: :string }
                                                   }
                                               }
                                           }
                                       }

                                   }
                               }
                           }
                       }
                   },
                   meta: {
                       type: :object,
                       properties: {
                           total_count:    { type: :integer },
                           current_page:   { type: :integer },
                           total_pages:    { type: :integer },
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/trains/all_records.xlsx' do
    get 'Export 培訓記錄-全部記錄' do
      tags '培訓記錄-全部記錄'
      parameter name: :locale,           in: :query, type: :string, description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :empoid,           in: :query, type: :string, description: '員工編號'
      parameter name: :name,             in: :query, type: :string, description: '員工姓名'
      parameter name: :department,       in: :query, type: :string, description: '部門'
      parameter name: :position,         in: :query, type: :string, description: '職位'
      parameter name: :train_name,       in: :query, type: :string, description: '培訓名稱'
      parameter name: :train_number,     in: :query, type: :string, description: '培訓編號'
      parameter name: :date_of_train,    in: :query, type: :string, description: '培訓日期'
      parameter name: :train_type,       in: :query, type: :string, description: '培訓種類'
      parameter name: :train_cost,       in: :query, type: :string, description: '培訓費用'
      parameter name: :attendance_rate,  in: :query, type: :string, description: '出席率'
      parameter name: :train_result,     in: :query, type: :boolean, description: '培訓結果'
      response '200', 'all_records found' do
        run_test!
      end
    end
  end

  path '/trains/columns_by_all_records' do
    get 'Get columns' do
      tags '培訓記錄-全部記錄'
      response '200', 'got columns' do
        schema type: :array,
               items: {
                   type: :object,
                   properties: {
                       key: { type: :string },
                       chinese_name: { type: :string },
                       english_name: { type: :string },
                       simple_chinese_name: { type: :string }
                   }
               }
        run_test!
      end
    end
  end

  path '/trains/field_options_by_all_records' do
    get 'Get options' do
      tags '培訓記錄-全部記錄'
      response '200', 'got options' do
        schema type: :object,
               properties: {
                   departments: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               department_chinese_name: { type: :string },
                               department_english_name: { type: :string },
                               department_simple_chinese_name: { type: :string },
                           }
                       }
                   },
                   positions: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               position_chinese_name: { type: :string },
                               position_english_name: { type: :string },
                               position_simple_chinese_name: { type: :string },
                           }
                       }
                   },
                   train_names: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               chinese_name: { type: :string },
                               english_name: { type: :string },
                               simple_chinese_name: { type: :string },
                           }
                       }
                   },
                   train_template_types: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               chinese_name: { type: :string },
                               english_name: { type: :string },
                               simple_chinese_name: { type: :string },
                           }
                       }
                   },
                   train_results: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               key: { type: :boolean },
                               chinese_name: { type: :string },
                               english_name: { type: :string },
                               simple_chinese_name: { type: :string },
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end
end