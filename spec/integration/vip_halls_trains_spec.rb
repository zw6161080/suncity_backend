require 'swagger_helper'

describe 'Vip Halls Trains API' do

  path '/vip_halls_trains' do
    get 'Index vip_halls_trains' do
      tags '贵宾厅场馆培训记录'
      parameter name: :location_id, in: :query, type: :integer
      parameter name: :train_month, in: :query, type: :string
      response '200', 'vip_halls_trains found' do
        schema type: :object,
               properties: {
                   data: {
                       type: 'array',
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               location_id: { type: :integer },
                               train_month: { type: :string, description: '培训月份' },
                               locked: { type: :boolean, description: '是否锁定' },
                               employee_amount: { type: :integer, description: '場館內員工人数' },
                               training_minutes_available: { type: :integer, description: '場館提供培訓總時數' },
                               training_minutes_accepted: { type: :integer, description: '員工接受培訓總時數' },
                               training_minutes_per_employee: { type: :integer, description: '員工平均培訓時數' },
                               location: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
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
                       }
                   }
               }
        run_test!
      end
    end

    post 'Create a VIP-halls-train record' do
      tags '贵宾厅场馆培训记录'
      parameter name: :vip_halls_train, in: :body, schema: {
          type: :object,
          properties: {
              train_month: { type: :string },
              location_ids: {
                  type: 'array',
                  items: { type: :integer }
              },
          },
          required: [ 'train_month', 'location_ids' ]
      }
      response '201', 'vip_halls_train created' do
        let(:vip_halls_train) { { train_month: '2017/10', location_ids: [1,2,3] } }
        run_test!
      end
    end
  end

  path '/vip_halls_trains/{id}/lock' do
    patch 'Lock one VIP-halls-train record' do
      tags '贵宾厅场馆培训记录'
      parameter name: :id, in: :path, type: :integer
      response '200', 'the vip_halls_train has been locked' do
        let(:id) { 51 }
        run_test!
      end
    end
  end

  path '/vip_halls_trains/field_options' do
    get 'Get options on the top' do
      tags '贵宾厅场馆培训记录'
      response '200', 'got options on the top' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           train_months: {
                               type: 'array',
                               items: {
                                   type: :string,
                                   description: 'YYYY/MM'
                               }
                           },
                           locations: {
                               type: 'array',
                               items: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
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

  path '/vip_halls_trains/options_of_all_locations' do
    get 'Get options of all locations while creating a VIP-halls-train record' do
      tags '贵宾厅场馆培训记录'
      response '200', 'got options of all locations while creating a VIP-halls-train record' do
        schema type: :object,
               properties: {
                   data: {
                       type: 'array',
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
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

  path '/vip_halls_trains/which_locations_can_be_chosen' do
    get 'To see which locations can be chosen while creating a VIP-halls-train record' do
      tags '贵宾厅场馆培训记录'
      parameter name: :train_month, in: :query, type: :string
      response '200', 'got the ids of the locations that can be chosen while creating a VIP-halls-train record' do
        schema type: 'array',
               items: { type: :integer }
        run_test!
      end
    end
  end

end