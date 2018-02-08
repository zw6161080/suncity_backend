require 'swagger_helper'

describe 'Performance Interview API' do

  path '/appraisals/{appraisal_id}/performance_interviews' do
    get '绩效面谈-展示列表' do
      tags '360评核-详情页（績效面談）'
      parameter name: :appraisal_id,                     in: :path, type: :integer, description: '360评核id'
      parameter name: :locale,                           in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                             in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,                      in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,                   in: :query, type: :string,  description: '排序方向'

      parameter name: :empoid,                           in: :query, type: :string, description: '员工编号'
      parameter name: :name,                             in: :query, type: :string, description: '姓名'
      parameter name: :department,                       in: :query, type: :array,  items: { type: :integer, description: '部门' }
      parameter name: :position,                         in: :query, type: :array,  items: { type: :integer, description: '职位' }
      parameter name: :grade,                            in: :query, type: :array,  items: { type: :integer, description: '职级' }
      parameter name: :division_of_job,                  in: :query, type: :string, description: '员工归属类别'
      parameter name: :date_of_employment,               in: :query, type: :string, description: '入职日期'
      parameter name: :interview_date,                   in: :query, type: :string, description: '面谈日期'
      parameter name: :interview_time,                   in: :query, type: :string, description: '面谈时间'
      parameter name: :operator,                         in: :query, type: :string, description: '录入人'
      parameter name: :operator_at,                      in: :query, type: :string, description: '录入日期'
      parameter name: :performance_moderator,            in: :query, type: :string, description: '面谈主持人'
      parameter name: :appraisal_attachments,            in: :query, type: :string, description: '相关文件'
      parameter name: :performance_interview_status,     in: :query, type: :array,   items: { type: :string, description: '面谈状态 enum: {not completed, completed}' }

      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           id:                              { type: :integer },
                           interview_date:                  { type: :string },
                           interview_time:                  { type: :string },
                           operator_at:                     { type: :string },
                           performance_interview_status:    { type: :string },
                           appraisal:{
                               type: :object,
                               properties:{
                                   appraisal_attachments:{
                                       type: :array,
                                       properties:{
                                           file_name:  {type: :string}
                                       }
                                   }
                               }
                           },
                           attachment_items:{
                               type: :array,
                               properties:{
                                   file_name:  {type: :string}
                               }
                           },
                           appraisal_participator:{
                               type: :object,
                               properties: {
                                   user:{
                                       type: :object,
                                       properties: {
                                           id:                  { type: :integer },
                                           empoid:              { type: :string },
                                           grade:               { type: :integer },
                                           chinese_name:        { type: :string },
                                           english_name:        { type: :string },
                                           simple_chinese_name: { type: :string },
                                           location: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           department: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           position: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           profile: {
                                               type: :object,
                                               properties: {
                                                   data: {
                                                       type: :object,
                                                       properties: {
                                                           position_information: {
                                                               type: :object,
                                                               properties: {
                                                                   field_values: {
                                                                       type: :object,
                                                                       properties: {
                                                                           division_of_job:      { type: :string },
                                                                           employment_status:    { type: :string },
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                           },
                           operator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
                               }
                           },
                           performance_moderator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
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
               }
      end
    end
  end

  path '/appraisals/{appraisal_id}/performance_interviews/index_by_mine' do
    get '(我的)绩效面谈-展示列表' do
      tags '360评核-详情页（績效面談）'
       response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           id:                              { type: :integer },
                           interview_date:                  { type: :string },
                           interview_time:                  { type: :string },
                           operator_at:                     { type: :string },
                           performance_interview_status:    { type: :string },
                           appraisal:{
                               type: :object,
                               properties:{
                                   appraisal_attachments:{
                                       type: :array,
                                       properties:{
                                           file_name:  {type: :string}
                                       }
                                   }
                               }
                           },
                           attachment_items:{
                               type: :array,
                               properties:{
                                   file_name:  {type: :string}
                               }
                           },
                           appraisal_participator:{
                               type: :object,
                               properties: {
                                   user:{
                                       type: :object,
                                       properties: {
                                           id:                  { type: :integer },
                                           empoid:              { type: :string },
                                           grade:               { type: :integer },
                                           chinese_name:        { type: :string },
                                           english_name:        { type: :string },
                                           simple_chinese_name: { type: :string },
                                           location: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           department: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           position: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           profile: {
                                               type: :object,
                                               properties: {
                                                   data: {
                                                       type: :object,
                                                       properties: {
                                                           position_information: {
                                                               type: :object,
                                                               properties: {
                                                                   field_values: {
                                                                       type: :object,
                                                                       properties: {
                                                                           division_of_job:      { type: :string },
                                                                           employment_status:    { type: :string },
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                           },
                           operator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
                               }
                           },
                           performance_moderator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
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
               }
      end
    end
  end

  path '/appraisals/{appraisal_id}/performance_interviews/index_by_department' do
    get '(部门)绩效面谈-展示列表' do
      tags '360评核-详情页（績效面談）'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           id:                              { type: :integer },
                           interview_date:                  { type: :string },
                           interview_time:                  { type: :string },
                           operator_at:                     { type: :string },
                           performance_interview_status:    { type: :string },
                           appraisal:{
                               type: :object,
                               properties:{
                                   appraisal_attachments:{
                                       type: :array,
                                       properties:{
                                           file_name:  {type: :string}
                                       }
                                   }
                               }
                           },
                           attachment_items:{
                               type: :array,
                               properties:{
                                   file_name:  {type: :string}
                               }
                           },
                           appraisal_participator:{
                               type: :object,
                               properties: {
                                   user:{
                                       type: :object,
                                       properties: {
                                           id:                  { type: :integer },
                                           empoid:              { type: :string },
                                           grade:               { type: :integer },
                                           chinese_name:        { type: :string },
                                           english_name:        { type: :string },
                                           simple_chinese_name: { type: :string },
                                           location: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           department: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           position: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           profile: {
                                               type: :object,
                                               properties: {
                                                   data: {
                                                       type: :object,
                                                       properties: {
                                                           position_information: {
                                                               type: :object,
                                                               properties: {
                                                                   field_values: {
                                                                       type: :object,
                                                                       properties: {
                                                                           division_of_job:      { type: :string },
                                                                           employment_status:    { type: :string },
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                           },
                           operator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
                               }
                           },
                           performance_moderator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
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
               }
      end
    end
  end

  path '/appraisals/{appraisal_id}/performance_interviews/options' do
    get '获取下拉列表' do
      tags '360评核-详情页（績效面談）'
      response '200', 'got options' do
        schema type: :object,
               items: {
                   type: :object,
                   properties: {
                       options: {
                           type: :array,
                           properties: {
                               key:                     { type: :string },
                               chinese_name:            { type: :string },
                               english_name:            { type: :string },
                               simple_chinese_name:     { type: :string },
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisals/{appraisal_id}/performance_interviews/columns' do
    get '获取表头' do
      tags '360评核-详情页（績效面談）'
      response '200', 'got columns' do
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

  path '/appraisals/{appraisal_id}/performance_interviews/{id}' do
    patch '更新' do
      tags '360评核-详情页(績效面談)'
      response '200', 'got update' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           id:                              { type: :integer },
                           interview_date:                  { type: :string },
                           interview_time:                  { type: :string },
                           operator_at:                     { type: :string },
                           performance_interview_status:    { type: :string },
                           attachment_items:{
                               type: :array,
                               properties:{
                                   file_name:  {type: :string}
                               }
                           },
                           operator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
                               }
                           },
                           performance_moderator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
                               }
                           }
                       },
                   }
               }
      end
    end
  end

  path '/appraisals/{appraisal_id}/performance_interviews/side_bar_options' do
    patch '获取旁边列表' do
      tags '360评核-详情页(績效面談)'
      response '200', 'got side_bar_options' do
        schema type: :array,
               items: {
                   type: :object,
                   properties: {
                       chinese_name:                 { type: :string },
                       english_name:                 { type: :string },
                       simple_chinese_name:          { type: :string },
                       count:                        { type: :integer },
                       key:                          { type: :string },
                   }
               }
        run_test!
      end
    end
  end


  path '/appraisal_records/performance_interviews/records' do
    get '绩效面谈-展示列表' do
      tags '评核记录-绩效面谈'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           id:                              { type: :integer },
                           interview_date:                  { type: :string },
                           interview_time:                  { type: :string },
                           operator_at:                     { type: :string },
                           performance_interview_status:    { type: :string },
                           appraisal:{
                               type: :object,
                               properties:{
                                   appraisal_date:       { type: :string },
                                   appraisal_name:       { type: :string },
                                   appraisal_attachments:{
                                       type: :array,
                                       properties:{
                                           file_name:  {type: :string}
                                       }
                                   }
                               }
                           },
                           appraisal_participator:{
                               type: :object,
                               properties: {
                                   user:{
                                       type: :object,
                                       properties: {
                                           id:                  { type: :integer },
                                           empoid:              { type: :string },
                                           grade:               { type: :integer },
                                           chinese_name:        { type: :string },
                                           english_name:        { type: :string },
                                           simple_chinese_name: { type: :string },
                                           location: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           department: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           position: {
                                               type: :object,
                                               properties: {
                                                   id:                  { type: :integer },
                                                   chinese_name:        { type: :string },
                                                   english_name:        { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           profile: {
                                               type: :object,
                                               properties: {
                                                   data: {
                                                       type: :object,
                                                       properties: {
                                                           position_information: {
                                                               type: :object,
                                                               properties: {
                                                                   field_values: {
                                                                       type: :object,
                                                                       properties: {
                                                                           division_of_job:      { type: :string },
                                                                           employment_status:    { type: :string },
                                                                       }
                                                                   }
                                                               }
                                                           }
                                                       }
                                                   }
                                               }
                                           }
                                       }
                                   }
                               }
                           },
                           operator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
                               }
                           },
                           performance_moderator: {
                               type: :object,
                               properties: {
                                   chinese_name:          { type: :integer },
                                   english_name:          { type: :integer },
                                   simple_chinese_name:   { type: :integer },
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
               }
      end
    end
  end

  path '/appraisal_records/performance_interviews/columns' do
    get '获取表头' do
      tags '评核记录-绩效面谈'
      response '200', 'got columns' do
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

  path '/appraisal_records/performance_interviews/options' do
    get '获取下拉选项' do
      tags '评核记录-绩效面谈'
      response '200', 'got options' do
        schema type: :object,
               items: {
                   type: :object,
                   properties: {
                       options: {
                           type: :array,
                           properties: {
                               key:                     { type: :string },
                               chinese_name:            { type: :string },
                               english_name:            { type: :string },
                               simple_chinese_name:     { type: :string },
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

end