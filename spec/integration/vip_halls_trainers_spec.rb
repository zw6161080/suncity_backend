require 'swagger_helper'

describe 'Vip Halls Trainers API' do

  path '/vip_halls_trainers' do
    get 'Index vip_halls_trainers' do
      tags '贵宾厅场馆培训记录'
      parameter name: :inspector, in: :query, type: :string, description: '必须传。可取两个值：hr / department。'
      parameter name: :vip_halls_train_id, in: :query, type: :integer, description: '当inspector取hr时，必须传此参数。'
      parameter name: :location_id, in: :query, type: :integer, description: '当inspector取department时，必须传此参数。'
      parameter name: :train_month, in: :query, type: :string, description: '当inspector取department时，可选择传此参数。形如YYYY/MM'
      response '200', 'vip_halls_trainers found' do
        schema type: :object,
               properties: {
                   data: {
                       type: 'array',
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               vip_halls_train_id: { type: :integer },
                               train_date_begin: { type: :string, description: '培訓開始時間 YYYY-MM-DDThh:mm' },
                               train_date_end: { type: :string, description: '培訓結束時間 YYYY-MM-DDThh:mm' },
                               length_of_training_time: { type: :integer, description: '培訓時長(分钟)' },
                               train_content: { type: :string, description: '培訓內容' },
                               user_id: { type: :integer },
                               train_type: { type: :string, description: '值有2种：individual_training / group_training' },
                               number_of_students: { type: :integer, description: '同時上課人數' },
                               total_accepted_training_time: { type: :integer, description: '員工接受培訓總時數(分钟)' },
                               remarks: { type: :string, description: '備註' },
                               user: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       empoid: { type: :string },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
                                   }
                               }
                           }
                       }
                   },
                   meta: {
                       type: :object,
                       properties: {
                           total_count: { type: :integer },
                           current_page: { type: :integer },
                           total_pages: { type: :integer },
                           sort_column: { type: :string },
                           sort_direction: { type: :string },
                           header_number_of_people_on_the_1st_day: {
                               type: :integer,
                               description: '页面顶端-每月1日場館人數'
                           },
                           header_score: {
                               type: :integer,
                               description: '页面顶端-評分'
                           },
                           header_total_training_time_provided: {
                               type: :integer,
                               description: '页面顶端-場館提供培訓總時數(分钟)'
                           },
                           header_total_training_time_accepted: {
                               type: :integer,
                               description: '页面顶端-員工接受培訓總時數(分钟)'
                           },
                           header_average_training_time_accepted: {
                               type: :integer,
                               description: '页面顶端-員工平均培訓時數(分钟)'
                           },
                           locked: { type: :boolean }
                       }
                   }
               }
        run_test!
      end
    end

    post 'Create a VIP-halls-trainer record' do
      tags '贵宾厅场馆培训记录'
      parameter name: :vip_halls_trainer, in: :body, schema: {
          type: :object,
          properties: {
              vip_halls_train_id: { type: :integer },
              train_date_begin: { type: :string, description: 'YYYY/MM/DD hh:mm' },
              train_date_end: { type: :string, description: 'YYYY/MM/DD hh:mm' },
              train_content: { type: :string },
              user_id: { type: :integer },
              train_type: { type: :string, description: '值取其一：individual_training / group_training' },
              number_of_students: { type: :integer },
              remarks: { type: :string },
          },
          required: [ 'vip_halls_train_id', 'train_date_begin', 'train_date_end', 'train_content', 'user_id', 'train_type', 'number_of_students', 'remarks' ]
      }
      response '201', 'vip_halls_trainer created' do
        let(:vip_halls_trainer) { { vip_halls_train_id: 51,
                                    train_date_begin: '2017/06/01 09:00',
                                    train_date_end: '2017/06/01 16:00',
                                    train_content: '培训内容',
                                    user_id: 1,
                                    train_type: 'group_training',
                                    number_of_students: 20,
                                    remarks: '备注' } }
        run_test!
      end
    end
  end

  path '/vip_halls_trainers/{id}' do
    patch 'Update a vip_halls_trainer' do
      tags '贵宾厅场馆培训记录'
      parameter name: :id, in: :path, type: :integer
      parameter name: :vip_halls_trainer, in: :body, schema: {
          type: :object,
          properties: {
              train_date_begin: { type: :string, description: 'YYYY/MM/DD hh:mm' },
              train_date_end: { type: :string, description: 'YYYY/MM/DD hh:mm' },
              train_content: { type: :string },
              user_id: { type: :integer },
              train_type: { type: :string, description: '值取其一：individual_training / group_training' },
              number_of_students: { type: :integer },
              remarks: { type: :string },
          }
      }
      response '200', 'have updated a vip_halls_trainer' do
        let(:vip_halls_trainer) { { train_date_begin: '2017/05/25 15:00',
                                    train_date_end: '2017/05/25 17:00',
                                    train_content: '健身授课方式培训',
                                    user_id: @user1.id,
                                    train_type: 'group_training',
                                    number_of_students: 99,
                                    remarks: '健身培训备注' } }
        run_test!
      end
    end
  end

  path '/vip_halls_trainers/export' do
    get 'Export vip_halls_trainers' do
      tags '贵宾厅场馆培训记录'
      parameter name: :inspector, in: :query, type: :string, description: '必须传。可取两个值：hr / department。'
      parameter name: :vip_halls_train_id, in: :query, type: :integer, description: '当inspector取hr时，传此参数。'
      parameter name: :location_id, in: :query, type: :integer, description: '当inspector取department时，必须传此参数。'
      parameter name: :train_month, in: :query, type: :string, description: '当inspector取department时，可选择传此参数。形如YYYY/MM'
      response '200', 'export success' do
        run_test!
      end
    end
  end

  path '/vip_halls_trainers/columns' do
    get 'Get columns' do
      tags '贵宾厅场馆培训记录'
      response '200', 'got columns' do
        schema type: 'array',
               items: {
                   type: :object,
                   properties: {
                       key: { type: :string },
                       chinese_name: { type: :string },
                       english_name: { type: :string },
                       simple_chinese_name: { type: :string },
                       value_type: { type: :string },
                       value_format: { type: :string },
                       search_attribute: { type: :string }
                   }
               }
        run_test!
      end
    end
  end

  path '/vip_halls_trainers/month_options' do
    get 'Get month options' do
      tags '贵宾厅场馆培训记录'
      parameter name: :location_id, in: :query, type: :integer
      response '200', 'got month options' do
        schema type: :object,
               properties: {
                   data: {
                       type: 'array',
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               train_month: {
                                   type: :string,
                                   description: 'YYYY/MM'
                               }
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

end