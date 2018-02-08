require 'swagger_helper'

describe 'Trains All Trains API' do

  path '/trains/all_trains.json' do
    get 'Index 培訓記錄-員工參加培訓明細' do
      tags '培訓記錄-員工參加培訓明細'
      parameter name: :locale,                  in: :query, type: :string, description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :empoid,                  in: :query, type: :string, description: '員工編號'
      parameter name: :name,                    in: :query, type: :string, description: '員工姓名'
      parameter name: :department_id,           in: :query, type: :integer, description: '部門id'
      parameter name: :position_id,             in: :query, type: :integer, description: '職位id'
      parameter name: :date_of_employment_begin,in: :query, type: :string, description: '入職日期begin'
      parameter name: :date_of_employment_end  ,in: :query, type: :string, description: '入職日期end'

      response '200', 'all_trains found' do
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
                               department_id: { type: :integer },
                               position_id: { type: :integer },
                               department: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               },
                               position: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               },
                               profile: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       data: {
                                           type: :object,
                                           properties: {
                                               career_history: { type: :object },
                                               salary_history: { type: :object },
                                               welfare_history: { type: :object },
                                               lent_information: { type: :object },
                                               museum_information: { type: :object },
                                               salary_information: { type: :object },
                                               holiday_information: { type: :object },
                                               personal_information: { type: :object },
                                               position_information: {
                                                   type: :object,
                                                   properties: {
                                                       field_values: {
                                                           type: :object,
                                                           properties: {
                                                               date_of_employment: { type: :string, description: '入職日期'}
                                                           }
                                                       },
                                                       filed_values: {
                                                           type: :object
                                                       },
                                                   }
                                               },
                                               resignation_information: { type: :object }
                                           }
                                       }
                                   }
                               },
                               trains: {
                                   type: :array,
                                   items: {
                                       type: :object,
                                       properties: {
                                           id: { type: :integer },
                                           chinese_name: { type: :string },
                                           english_name: { type: :string },
                                           simple_chinese_name: { type: :string },
                                           train_date_begin: { type: :string },
                                           train_date_end: { type: :string }
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
                           total_pages:    { type: :integer }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/trains/all_trains.xlsx' do
    get 'Export 培訓記錄-員工參加培訓明細' do
      tags '培訓記錄-員工參加培訓明細'
      parameter name: :locale,            in: :query, type: :string, description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :empoid,            in: :query, type: :string, description: '員工編號'
      parameter name: :name,              in: :query, type: :string, description: '員工姓名'
      parameter name: :department_id,     in: :query, type: :string, description: '部門id'
      parameter name: :position_id,       in: :query, type: :string, description: '職位id'
      parameter name: :date_of_employment,in: :query, type: :string, description: '入職日期'
      parameter name: :date_of_employment,in: :query, type: :string, description: '入職日期'
      response '200', 'all_trains found' do
        run_test!
      end
    end
  end

  path '/trains/columns_by_all_trains' do
    get 'Get columns' do
      tags '培訓記錄-員工參加培訓明細'
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

  path '/trains/field_options_by_all_trains' do
    get 'Get options' do
      tags '培訓記錄-員工參加培訓明細'
      response '200', 'got options' do
        schema type: :object,
               properties: {
                   departments: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               chinese_name: { type: :string },
                               english_name: { type: :string },
                               simple_chinese_name: { type: :string }
                           }
                       }
                   },
                   positions: {
                       type: :array,
                       items: {
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
        run_test!
      end
    end
  end
end