require 'swagger_helper'

describe 'Appraisal API' do

  path 'appraisals/can_create' do
    post '检查是否可以新建360评核' do
      tags '360评核-列表页'
      parameter name: :appraisal, in: :body, schema: {
        type: :object,
        properties: {
          appraisal_name: { type: :string },
          date_begin:     { type: :string, description: 'YYYY/MM/DD' },
          date_end:       { type: :string, description: 'YYYY/MM/DD' },
          location:       { type: :array, items: { type: :integer } },
          department:     { type: :array, items: { type: :integer } },
          position:       { type: :array, items: { type: :integer } },
          grade:          { type: :array, items: { type: :integer } },
          date_of_employment: { type: :object,
                                properties: {
                                  begin: { type: :string, description: 'YYYY/MM/DD' },
                                  end:   { type: :string, description: 'YYYY/MM/DD' }
                                }}
        },
        required: [:appraisal_name, :date_begin, :date_end, :location, :department, :position, :grade, :date_of_employment ]
      }
      response '200', 'created an appraisal' do
        run_test!
      end
    end
  end

  path '/appraisals' do
    post '新增360评核' do
      tags '360评核-列表页'
      parameter name: :appraisal, in: :body, schema: {
          type: :object,
          properties: {
              appraisal_name: { type: :string },
              date_begin:     { type: :string, description: 'YYYY/MM/DD' },
              date_end:       { type: :string, description: 'YYYY/MM/DD' },
              location:       { type: :array, items: { type: :integer } },
              department:     { type: :array, items: { type: :integer } },
              position:       { type: :array, items: { type: :integer } },
              grade:          { type: :array, items: { type: :integer } },
              date_of_employment: { type: :object,
                                    properties: {
                                        begin: { type: :string, description: 'YYYY/MM/DD' },
                                        end:   { type: :string, description: 'YYYY/MM/DD' }
                                    }}
          },
          required: [:appraisal_name, :date_begin, :date_end, :location, :department, :position, :grade, :date_of_employment ]
      }
      response '200', 'created an appraisal' do
        run_test!
      end
    end

    get '获取列表' do
      tags '360评核-列表页'
      parameter name: :locale,                    in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                      in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,               in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,            in: :query, type: :string,  description: '排序方向'
      parameter name: :appraisal_status,          in: :query, type: :array,   items: { type: :string, description: 'enum: {unpublished，to_be_assessed，assessing，completed}' }
      parameter name: :appraisal_date,            in: :query, type: :object,  properties: { begin: { type: :string, description: '評核日期(起)，YYYY/MM/DD。' },
                                                                                            end:   { type: :string, description: '評核日期(止)，YYYY/MM/DD。' } }
      parameter name: :participator_amount,       in: :query, type: :integer, description: '參加評核人數'
      parameter name: :ave_total_appraisal,       in: :query, type: :string,  description: '平均總分'
      parameter name: :ave_superior_appraisal,    in: :query, type: :string,  description: '上司評核平均分'
      parameter name: :ave_colleague_appraisal,   in: :query, type: :string,  description: '同事評核平均分'
      parameter name: :ave_subordinate_appraisal, in: :query, type: :string,  description: '下屬評核平均分'
      parameter name: :ave_self_appraisal,        in: :query, type: :string,  description: '自我評核平均分'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           id:                        { type: :integer },
                           appraisal_status:          { type: :string },
                           appraisal_name:            { type: :string },
                           participator_amount:       { type: :integer },
                           ave_total_appraisal:       { type: :string },
                           ave_superior_appraisal:    { type: :string },
                           ave_colleague_appraisal:   { type: :string },
                           ave_subordinate_appraisal: { type: :string },
                           ave_self_appraisal:        { type: :string },
                           appraisal_date:            { type: :string }
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

  path '/appraisals/{id}' do
    get '360评核-详情页（评核简介）' do
      tags '360评核-详情页'
      parameter name: :id, in: :path, type: :integer
      response '200', 'showed' do
        schema type: :object,
               proerpties: {
                   data: {
                       type: :object,
                       properties: {
                           id:                     { type: :integer },
                           appraisal_status:       { type: :string },
                           appraisal_name:         { type: :string },
                           date_begin:             { type: :string },
                           date_end:               { type: :string },
                           appraisal_introduction: { type: :string }
                       }
                   }
               }
        run_test!
      end
    end

    patch '修改360评核状态：公布，发起评核，完成评核' do
      tags '360评核-详情页'
      parameter name: :id, in: :path, type: :integer
      parameter name: :appraisal, in: :body, schema: {
          type: :object,
          properties: {
              appraisal_status: { type: :string }
          },
          required: [:appraisal_status]
      }
      response '200', 'updated appraisal_status' do
        run_test!
      end
    end
  end

  path '/appraisals/options' do
    get '获取下拉列表' do
      tags '360评核-列表页'
      response '200', 'got options' do
        schema type: :array,
               items: {
                   type: :object,
                   properties: {
                       key:                 { type: :string },
                       chinese_name:        { type: :string },
                       english_name:        { type: :string },
                       simple_chinese_name: { type: :string },
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisals/index_by_department' do
    get '部门的360评核-列表页' do
      tags '360评核-列表页'
      parameter name: :locale,                    in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                      in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,               in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,            in: :query, type: :string,  description: '排序方向'
      parameter name: :appraisal_status,          in: :query, type: :array,   items: { type: :string, description: 'enum: {unpublished，to_be_assessed，assessing，completed}' }
      parameter name: :appraisal_date,            in: :query, type: :object,  properties: { begin: { type: :string, description: '評核日期(起)，YYYY/MM/DD。' },
                                                                                            end:   { type: :string, description: '評核日期(止)，YYYY/MM/DD。' } }
      parameter name: :count,                     in: :query, type: :integer, description: '公司參加評核人數'
      parameter name: :count_of_department,       in: :query, type: :integer, description: '部門參加評核人數'
      parameter name: :ave_total_appraisal,       in: :query, type: :string,  description: '公司平均總分'
      parameter name: :ave_of_department,         in: :query, type: :string,  description: '部門平均總分'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       items: {
                           id:                          {type: :integer},
                           appraisal_date:              {type: :string},
                           appraisal_name:              {type: :string},
                           appraisal_status:            {type: :string},
                           ave_of_department:           {type: :integer},
                           ave_of_mine:                 {type: :integer},
                           ave_total_appraisal:         {type: :integer},
                           count:                       {type: :integer},
                           count_of_department:         {type: :integer},
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

  path 'appraisals/index_by_mine' do
    get '我的360评核-列表页' do
      tags '360评核-列表页'
      parameter name: :locale,                    in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                      in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,               in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,            in: :query, type: :string,  description: '排序方向'
      parameter name: :appraisal_status,          in: :query, type: :array,   items: { type: :string, description: 'enum: {unpublished，to_be_assessed，assessing，completed}' }
      parameter name: :appraisal_date,            in: :query, type: :object,  properties: { begin: { type: :string, description: '評核日期(起)，YYYY/MM/DD。' },
                                                                                            end:   { type: :string, description: '評核日期(止)，YYYY/MM/DD。' } }
      parameter name: :count,                     in: :query, type: :integer, description: '公司參加評核人數'
      parameter name: :count_of_department,       in: :query, type: :integer, description: '部門參加評核人數'
      parameter name: :ave_total_appraisal,       in: :query, type: :string,  description: '公司平均總分'
      parameter name: :ave_of_department,         in: :query, type: :string,  description: '部門平均總分'
      parameter name: :ave_of_mine,               in: :query, type: :string,  description: '個人平均總分'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       items: {
                           id:                          {type: :integer},
                           appraisal_date:              {type: :string},
                           appraisal_name:              {type: :string},
                           appraisal_status:            {type: :string},
                           ave_of_department:           {type: :integer},
                           ave_of_mine:                 {type: :integer},
                           ave_total_appraisal:         {type: :integer},
                           count:                       {type: :integer},
                           count_of_department:         {type: :integer},
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