require 'swagger_helper'

describe 'Trains Records By Departments API' do

  path '/trains/records_by_departments.json' do
    get 'Index 培訓記錄-按部門' do
      tags '培訓記錄-按部門'
      parameter name: :locale,                  in: :query, type: :string, description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :department_name,         in: :query, type: :string, description: '部門'
      parameter name: :train_times,             in: :query, type: :string, description: '培訓次數'
      parameter name: :total_train_times,       in: :query, type: :string, description: '參加培訓員工總次數'
      parameter name: :total_train_costs,       in: :query, type: :string, description: '培訓總費用'
      parameter name: :average_train_costs,     in: :query, type: :string, description: '員工平均培訓費用'
      parameter name: :average_attendance_rate, in: :query, type: :string, description: '員工平均出席率'
      parameter name: :average_pass_rate,       in: :query, type: :string, description: '員工平均通過率'

      response '200', 'records_by_departments found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               department_chinese_name: { type: :string },
                               department_english_name: { type: :string },
                               department_simple_chinese_name: { type: :string },
                               train_times: { type: :string },
                               total_train_times: { type: :string },
                               average_train_costs: { type: :string },
                               average_attendance_rate: { type: :string },
                               average_pass_rate: { type: :string },
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/trains/records_by_departments.xlsx' do
    get 'Export 培訓記錄-按部門' do
      tags '培訓記錄-按部門'
      parameter name: :locale,                  in: :query, type: :string, description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :department_name,         in: :query, type: :string, description: '部門'
      parameter name: :train_times,             in: :query, type: :string, description: '培訓次數'
      parameter name: :total_train_times,       in: :query, type: :string, description: '參加培訓員工總次數'
      parameter name: :total_train_costs,       in: :query, type: :string, description: '培訓總費用'
      parameter name: :average_train_costs,     in: :query, type: :string, description: '員工平均培訓費用'
      parameter name: :average_attendance_rate, in: :query, type: :string, description: '員工平均出席率'
      parameter name: :average_pass_rate,       in: :query, type: :string, description: '員工平均通過率'

      response '200', 'records_by_departments found' do
        run_test!
      end
    end
  end

  path '/trains/columns_by_records_by_departments' do
    get 'Get columns' do
      tags '培訓記錄-按部門'
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
end