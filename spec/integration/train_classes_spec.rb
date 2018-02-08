require 'swagger_helper'

describe 'Train Classes API' do

  path '/train_classes' do
    get 'Get index 培训月历' do
      tags '培訓月曆'
      parameter name: :locale,     in: :query, type: :string,  description: '语言环境，值有三种 {en-US，zh-CN，zh-TW}'
      parameter name: :by_whom,    in: :query, type: :string,  description: 'by_department by_mine by_hr'
      parameter name: :year_month, in: :query, type: :string,  description: 'YYYY/MM'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:         { type: :integer },
                               title_id:   { type: :integer },
                               train_id:   { type: :integer },
                               time_begin: { type: :string, description: '培训课程时间（起）' },
                               time_end:   { type: :string, description: '培训课程时间（止）' },
                               date:       { type: :string, description: '培训课程日期，YYYY/MM/DD，前端要求加的指示' },
                               train: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       train_template_id:   { type: :integer },
                                       chinese_name:        { type: :string, description: '培训名称' },
                                       english_name:        { type: :string, description: '培训名称' },
                                       simple_chinese_name: { type: :string, description: '培训名称' },
                                       train_number:        { type: :string, description: '培训编号' },
                                       train_place:         { type: :string, description: '培训地点' },
                                       status:              { type: :string, description: '状态' },
                                       train_template: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               online_or_offline_training: { type: :string, description: '线上培训 online_training，线下培训 offline_training' }
                                           }
                                       }
                                   }
                               },
                               title: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       name: { type: :string }
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

  path '/train_classes/index_trains' do
    get 'Get index 培训课程' do
      tags '培训课程'
      parameter name: :locale,  in: :query, type: :string,  description: '语言环境，值有三种 {en-US，zh-CN，zh-TW}'
      parameter name: :page,    in: :query, type: :integer, description: '页面编号'
      parameter name: :by_whom, in: :query, type: :string,  description: 'by_department by_mine'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                      { type: :integer },
                               train_template_id:       { type: :integer },
                               status:                  { type: :string, description: '状态' },
                               chinese_name:            { type: :string, description: '培训名称' },
                               english_name:            { type: :string, description: '培训名称' },
                               simple_chinese_name:     { type: :string, description: '培训名称' },
                               train_number:            { type: :string, description: '培训编号' },
                               train_date_begin:        { type: :string, description: '培训日期（起）' },
                               train_date_end:          { type: :string, description: '培训日期（止）' },
                               registration_date_begin: { type: :string, description: '报名日期（起）' },
                               registration_date_end:   { type: :string, description: '报名日期（止）' },
                               registration_method:     { type: :string, description: '报名方式' },
                               entry_lists_count:       { type: :integer, description: '部門報名人數' },
                               final_lists_count:       { type: :integer, description: '部門出席人數' },
                               train_template: {
                                   type: :object,
                                   properties: {
                                       id:                         { type: :integer },
                                       train_template_type_id:     { type: :integer },
                                       training_credits:           { type: :string, description: '培训学分' },
                                       online_or_offline_training: { type: :string, description: '线上培训 online_training，线下培训 offline_training' },
                                       train_template_type: {
                                           type: :object,
                                           properties: {
                                               id:                  { type: :integer },
                                               chinese_name:        { type: :string, description: '培训种类' },
                                               english_name:        { type: :string, description: '培训种类' },
                                               simple_chinese_name: { type: :string, description: '培训种类' }
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
                           sort_column:    { type: :string },
                           sort_direction: { type: :string }
                       }
                   }
               }
        run_test!
      end
    end
  end

end