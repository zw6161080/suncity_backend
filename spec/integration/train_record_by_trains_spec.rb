require 'swagger_helper'

describe 'Train Record By Trains API' do

  path '/train_record_by_trains' do
    post 'Create 创建记录' do
      tags '培训记录-按培训课程'
      parameter name: :train_record_by_train, in: :body, schema: {
          type: :object,
          properties: {
              train_id: { type: :integer },
          },
          required: ['train_id']
      }
      response '200', 'train_record_by_train created' do
        run_test!
      end
    end

    get 'Index 获取列表' do
      tags '培训记录-按培训课程'
      parameter name: :locale,              in: :query, type: :string,  description: '语言环境，值有三种 {en-US，zh-CN，zh-TW}'
      parameter name: :page,                in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,         in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,      in: :query, type: :string,  description: '排序方向'
      parameter name: :train_id,            in: :query, type: :array,   items: { type: :integer, description: '培训名称，筛选排序的KEY都用train_id，下拉列表给后端返回一个数组' }
      parameter name: :train_number,        in: :query, type: :string,  description: '培训编号'
      parameter name: :train_date,          in: :query, type: :object,  properties: { begin: { type: :string, description: '培訓日期(起)，YYYY/MM/DD。' },
                                                                                 end:   { type: :string, description: '培訓日期(止)，YYYY/MM/DD。' } }
      parameter name: :train_type,          in: :query, type: :array,   items: { type: :integer, description: '培训种类，筛选排序的KEY都用train_type，下拉列表给后端返回一个数组' }
      parameter name: :train_cost,          in: :query, type: :string,  description: '培训总费用'
      parameter name: :final_list_count,    in: :query, type: :integer, description: '培训人数'
      parameter name: :entry_list_count,    in: :query, type: :integer, description: '培训报名人数'
      parameter name: :invited_count,       in: :query, type: :integer, description: '培训受邀人数'
      parameter name: :attendance_rate,     in: :query, type: :string,  description: '课程出席率，例如想搜【100%，98.56%，80.00%】，则分别输入【100或100.00，98.56，80或80.00】'
      parameter name: :passing_rate,        in: :query, type: :string,  description: '学员通过率，例如想搜【100%，98.56%，80.00%】，则分别输入【100或100.00，98.56，80或80.00】'
      parameter name: :satisfaction_degree, in: :query, type: :string,  description: '课程满意度，例如想搜【100%，98.56%，80.00%】，则分别输入【100或100.00，98.56，80或80.00】'
      response '200', 'train_record_by_trains found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                  { type: :integer },
                               train_id:            { type: :integer },
                               final_list_count:    { type: :integer, description: '培训人数' },
                               entry_list_count:    { type: :integer, description: '培训报名人数' },
                               invited_count:       { type: :integer, description: '培训受邀人数' },
                               attendance_rate:     { type: :string,  description: '课程出席率' },
                               passing_rate:        { type: :string,  description: '学员通过率' },
                               satisfaction_degree: { type: :string,  description: '课程满意度' },
                               train: {
                                   type: :object,
                                   description: '培训',
                                   properties: {
                                       id: { type: :integer },
                                       train_template_id:   { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simpl_chinese_name:  { type: :string },
                                       train_number:        { type: :string, description: '培训编号' },
                                       train_date_begin:    { type: :string, description: '培训日期（起）' },
                                       train_date_end:      { type: :string, description: '培训日期（止）' },
                                       train_cost:          { type: :string, description: '培训总费用' },
                                       train_template_type: {
                                           type: :object,
                                           description: '培训种类',
                                           properties: {
                                               id:                 { type: :integer },
                                               chinese_name:       { type: :string },
                                               english_name:       { type: :string },
                                               simpl_chinese_name: { type: :string }
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

  path '/train_record_by_trains/export' do
    get 'Export 汇出' do
      tags '培训记录-按培训课程'
      parameter name: :locale,              in: :query, type: :string,  description: '语言环境，值有三种 {en-US，zh-CN，zh-TW}'
      parameter name: :sort_column,         in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,      in: :query, type: :string,  description: '排序方向'
      parameter name: :train_id,            in: :query, type: :array,   items: { type: :integer, description: '培训名称，筛选排序的KEY都用train_id，下拉列表给后端返回一个数组' }
      parameter name: :train_number,        in: :query, type: :string,  description: '培训编号'
      parameter name: :train_date,          in: :query, type: :object,  properties: { begin: { type: :string, description: '培訓日期(起)，YYYY/MM/DD。' },
                                                                                      end:   { type: :string, description: '培訓日期(止)，YYYY/MM/DD。' } }
      parameter name: :train_type,          in: :query, type: :array,   items: { type: :integer, description: '培训种类，筛选排序的KEY都用train_type，下拉列表给后端返回一个数组' }
      parameter name: :train_cost,          in: :query, type: :string,  description: '培训总费用'
      parameter name: :final_list_count,    in: :query, type: :integer, description: '培训人数'
      parameter name: :entry_list_count,    in: :query, type: :integer, description: '培训报名人数'
      parameter name: :invited_count,       in: :query, type: :integer, description: '培训受邀人数'
      parameter name: :attendance_rate,     in: :query, type: :string,  description: '课程出席率，例如想搜【100%，98.56%，80.00%】，则分别输入【100或100.00，98.56，80或80.00】'
      parameter name: :passing_rate,        in: :query, type: :string,  description: '学员通过率，例如想搜【100%，98.56%，80.00%】，则分别输入【100或100.00，98.56，80或80.00】'
      parameter name: :satisfaction_degree, in: :query, type: :string,  description: '课程满意度，例如想搜【100%，98.56%，80.00%】，则分别输入【100或100.00，98.56，80或80.00】'
      response '200', 'train_record_by_trains exported' do
        run_test!
      end
    end
  end

  path '/train_record_by_trains/columns' do
    get 'Get columns' do
      tags '培训记录-按培训课程'
      response '200', 'got columns' do
        schema type: :array,
               items: {
                   type: :object,
                   properties: {
                       key:                 { type: :string },
                       chinese_name:        { type: :string },
                       english_name:        { type: :string },
                       simple_chinese_name: { type: :string }
                   }
               }
        run_test!
      end
    end
  end

  path '/train_record_by_trains/options' do
    get 'Get options' do
      tags '培训记录-按培训课程'
      response '200', 'got options' do
        schema type: :object,
               properties: {
                   train_id: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                 { type: :integer },
                               chinese_name:       { type: :string },
                               english_name:       { type: :string },
                               simpl_chinese_name: { type: :string }
                           }
                       }
                   },
                   train_type: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                 { type: :integer },
                               chinese_name:       { type: :string },
                               english_name:       { type: :string },
                               simpl_chinese_name: { type: :string }
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

end