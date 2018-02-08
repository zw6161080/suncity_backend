require 'swagger_helper'

describe 'Appraisal Report API' do

  path '/appraisals/{appraisal_id}/appraisal_reports' do
    get '(部门/我的/全部)评核记录-展示列表' do
      tags '360评核-详情页（评核记录）'
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
      parameter name: :appraisal_total_count,            in: :query, type: :string, description: '评核总数量'
      parameter name: :overall_score,                    in: :query, type: :string, description: '评核总分数'

      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_total_count:   {type: :integer},
                           overall_score:           {type: :integer},
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

  path '/appraisals/{appraisal_id}/appraisal_reports/index_by_mine' do
    get '(我的)评核记录-展示列表' do
      tags '360评核-详情页（评核记录）'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_total_count:   {type: :integer},
                           overall_score:           {type: :integer},
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

  path '/appraisals/{appraisal_id}/appraisal_reports/index_by_department' do
    get '(我的)评核记录-展示列表' do
      tags '360评核-详情页（评核记录）'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_total_count:   {type: :integer},
                           overall_score:           {type: :integer},
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

  path '/appraisals/{appraisal_id}/appraisal_reports/options' do
    get '获取下拉列表' do
      tags '360评核-详情页(评核记录)'
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

  path '/appraisals/{appraisal_id}/appraisal_reports/columns' do
    get '获取表头' do
      tags '360评核-详情页(评核记录)'
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

  path '/appraisals/{appraisal_id}/appraisal_reports/{id}' do
    get '获取某一份报告' do
      tags '360评核-详情页(评核报告)'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_total_count:   {type: :integer},
                           overall_score:           {type: :integer},
                           appraisal_group:         {type: :integer},
                           colleague_score:         {type: :integer},
                           self_score:              {type: :integer},
                           subordinate_score:       {type: :integer},
                           superior_score:          {type: :integer},
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
                           report_detail:{
                               type: :object,
                               properties: {
                                   assessor_count:      { type: :integer },
                                   colleague_count:     { type: :integer },
                                   subordinate_count:   { type: :integer },
                                   superior_count:      { type: :integer },
                                   differences_in_analysis:{
                                       type: :array,
                                       properties: {
                                           self_assess:          { type: :integer },
                                           colleague_assess:     { type: :integer },
                                           subordinate_assess:   { type: :integer },
                                           superior_assess:      { type: :integer },
                                           title:                { type: :string }
                                       }
                                   },
                                   differences_in_analysis_items:{
                                       type: :array,
                                       properties: {
                                           items:{
                                               type: :array,
                                               properties: {
                                                   self_assess:          { type: :integer },
                                                   colleague_assess:     { type: :integer },
                                                   subordinate_assess:   { type: :integer },
                                                   superior_assess:      { type: :integer },

                                               }
                                           },
                                       }
                                   },
                                   employee_in_group_strengths_and_weaknesses:{
                                       type: :array,
                                       properties: {
                                           departmental_average_value:          { type: :integer },
                                           personal_average_value:              { type: :integer },
                                           question_title:                      { type: :string },

                                       }
                                   },
                                   self_cognition:{
                                       type: :array,
                                       properties: {
                                           others_assess:          { type: :integer },
                                           self_assess:            { type: :integer },
                                           title:                  { type: :string },

                                       }
                                   },
                               }
                           }
                       },

                   }
               }
      end
    end
  end

  path '/appraisals/{appraisal_id}/appraisal_reports/side_bar_options' do
    patch '获取旁边列表' do
      tags '360评核-详情页(评核报告)'
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


  path '/appraisal_records/appraisal_reports/records' do
    get '评合记录-展示列表' do
      tags '评核记录-评合记录'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_report:{
                               type: :object,
                               properties: {
                                   superior_score:         { type: :integer },
                                   subordinate_score:      { type: :integer },
                                   self_score:             { type: :integer },
                                   overall_score:          { type: :integer },
                                   colleague_score:        { type: :integer },
                                   appraisal_participator:{
                                       type: :object,
                                       properties: {
                                           assessors_count:{
                                               type: :array,
                                               properties: {
                                                   colleague_assessors_count:     { type: :integer },
                                                   subordinate_assessors_count:   { type: :integer },
                                                   superior_assessors_count:      { type: :integer },
                                               }
                                           }
                                       }
                                   }
                               }
                           },
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
                           },
                       }
                   }
               }
      end
    end
  end

  path '/appraisal_records/appraisal_reports/columns' do
    get '获取表头' do
      tags '评核记录-评合记录'
      response '200', 'got columns' do
        schema type: :array,
               items: {
                   type: :object,
                   properties: {
                       key:                 { type: :string },
                       chinese_name:        { type: :string },
                       english_name:        { type: :string },
                       simple_chinese_name: { type: :string },
                       children: {
                           type: :array,
                           properties: {
                               key:                 { type: :string },
                               chinese_name:        { type: :string },
                               english_name:        { type: :string },
                               simple_chinese_name: { type: :string },
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisal_records/appraisal_reports/options' do
    get '获取下拉选项' do
      tags '评核记录-评合记录'
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

end