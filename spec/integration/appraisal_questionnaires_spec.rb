require 'swagger_helper'

describe 'Appraisal Questionnaire API' do

  path '/appraisals/{appraisal_id}/appraisal_questionnaires' do
    get '(部门/我的/全部)评核问卷-展示列表' do
      tags '360评核-详情页（评核问卷）'
      parameter name: :appraisal_id,                     in: :path, type: :integer, description: '360评核id'
      parameter name: :locale,                           in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                             in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,                      in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,                   in: :query, type: :string,  description: '排序方向'

      parameter name: :submit_date,                      in: :query, type: :string,  description: '提交日期'
      parameter name: :is_filled_in,                     in: :query, type: :boolean,  description: '问卷状态'
      parameter name: :assessor_empoid,                  in: :query, type: :string, description: '评核者员工编号'
      parameter name: :assessor_name,                    in: :query, type: :string, description: '评核者姓名'
      parameter name: :assessor_department,              in: :query, type: :array,  items: { type: :integer, description: '评核者部门' }
      parameter name: :assessor_position,                in: :query, type: :array,  items: { type: :integer, description: '评核者职位' }
      parameter name: :assessor_grade,                   in: :query, type: :array,  items: { type: :integer, description: '评核者职级' }
      parameter name: :place_of_birth,                   in: :query, type: :array,  items: { type: :integer, description: '评核者国籍' }
      parameter name: :participator_empoid,              in: :query, type: :string, description: '被评核者员工编号'
      parameter name: :participator_name,                in: :query, type: :string, description: '被评核者姓名'
      parameter name: :participator_department,          in: :query, type: :array,  items: { type: :integer, description: '被评核者部门' }
      parameter name: :participator_position,            in: :query, type: :array,  items: { type: :integer, description: '被评核者职位' }
      parameter name: :participator_grade,               in: :query, type: :array,  items: { type: :integer, description: '被评核者职级' }
      parameter name: :departmental_appraisal_group,     in: :query, type: :string, description: '被评核者组别'
      parameter name: :assess_type,                      in: :query, type: :string, description: '评核类型'
      parameter name: :release_user,                     in: :query, type: :string, description: '最新修订人'
      parameter name: :release_date,                     in: :query, type: :string, description: '最新修订日期'

      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_id:                     {type: :integer},
                           assess_type:                      {type: :string},
                           departmental_appraisal_group:     {type: :integer},
                           final_score:                      {type: :integer},
                           submit_date:                      {type: :integer},
                           appraisal_participator:{
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
                                   }
                           }
                       },
                           assessor:{
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
                                                   personal_information: {
                                                       type: :object,
                                                       properties: {
                                                           field_values: {
                                                               type: :object,
                                                               properties: {
                                                                   place_of_birth:    { type: :string, description: '国籍' },
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
                           questionnaire: {
                               type: :object,
                               properties: {
                                   id:                  { type: :integer },
                                   is_filled_in:        { type: :boolean },
                                   release_date:        { type: :string },
                                   submit_date:         { type: :string },
                                   matrix_single_choice_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           max_score:             { type: :integer },
                                           order_no:              { type: :integer },
                                           score:                 { type: :integer },
                                           score_of_question:     { type: :integer },
                                           title:                 { type: :string },
                                           value:                 { type: :string },
                                           matrix_single_choice_items:{
                                               type: :array,
                                               properties: {
                                                   score:             { type: :integer },
                                                   is_required:       { type: :boolean },
                                                   item_no:           { type: :integer },
                                                   question:          { type: :string },
                                                   right_answer:      { type: :string },
                                               }
                                           }
                                       }
                                   },
                                   choice_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           question:              { type: :string },
                                           order_no:              { type: :integer },
                                           answer:                { type: :string },
                                           is_required:           { type: :boolean },
                                           score:                 { type: :integer },
                                           value:                 { type: :integer },
                                           is_filled_in:          { type: :boolean },
                                           right_answer:          { type: :string },
                                       }
                                   },
                                   fill_in_the_blank_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           question:              { type: :string },
                                           order_no:              { type: :integer },
                                           answer:                { type: :string },
                                           is_required:           { type: :boolean },
                                           score:                 { type: :integer },
                                           value:                 { type: :integer },
                                           is_filled_in:          { type: :boolean },
                                           right_answer:          { type: :string },
                                       }
                                   },

                               }
                           },

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

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/index_by_mine' do
    get '(我的)评核问卷-展示列表' do
      tags '360评核-详情页（评核问卷）'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_id: {type: :integer},
                           assess_type: {type: :string},
                           departmental_appraisal_group: {type: :integer},
                           final_score: {type: :integer},
                           submit_date: {type: :integer},
                           appraisal_participator:{
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
                                   }
                               }
                           },
                           assessor:{
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
                                                   personal_information: {
                                                       type: :object,
                                                       properties: {
                                                           field_values: {
                                                               type: :object,
                                                               properties: {
                                                                   place_of_birth:    { type: :string, description: '国籍' },
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
                           questionnaire: {
                               type: :object,
                               properties: {
                                   id:                  { type: :integer },
                                   is_filled_in:        { type: :boolean },
                                   release_date:        { type: :string },
                                   submit_date:         { type: :string },
                                   matrix_single_choice_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           max_score:             { type: :integer },
                                           order_no:              { type: :integer },
                                           score:                 { type: :integer },
                                           score_of_question:     { type: :integer },
                                           title:                 { type: :string },
                                           value:                 { type: :string },
                                           matrix_single_choice_items:{
                                               type: :array,
                                               properties: {
                                                   score:             { type: :integer },
                                                   is_required:       { type: :boolean },
                                                   item_no:           { type: :integer },
                                                   question:          { type: :string },
                                                   right_answer:      { type: :string },
                                               }
                                           }
                                       }
                                   },
                                   choice_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           question:              { type: :string },
                                           order_no:              { type: :integer },
                                           answer:                { type: :string },
                                           is_required:           { type: :boolean },
                                           score:                 { type: :integer },
                                           value:                 { type: :integer },
                                           is_filled_in:          { type: :boolean },
                                           right_answer:          { type: :string },
                                       }
                                   },
                                   fill_in_the_blank_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           question:              { type: :string },
                                           order_no:              { type: :integer },
                                           answer:                { type: :string },
                                           is_required:           { type: :boolean },
                                           score:                 { type: :integer },
                                           value:                 { type: :integer },
                                           is_filled_in:          { type: :boolean },
                                           right_answer:          { type: :string },
                                       }
                                   },

                               }
                           },

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

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/index_by_department' do
    get '(部门)评核问卷-展示列表' do
      tags '360评核-详情页（评核问卷）'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           appraisal_id: {type: :integer},
                           assess_type: {type: :string},
                           departmental_appraisal_group: {type: :integer},
                           final_score: {type: :integer},
                           submit_date: {type: :integer},
                           appraisal_participator:{
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
                                   }
                               }
                           },
                           assessor:{
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
                                                   personal_information: {
                                                       type: :object,
                                                       properties: {
                                                           field_values: {
                                                               type: :object,
                                                               properties: {
                                                                   place_of_birth:    { type: :string, description: '国籍' },
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
                           questionnaire: {
                               type: :object,
                               properties: {
                                   id:                  { type: :integer },
                                   is_filled_in:        { type: :boolean },
                                   release_date:        { type: :string },
                                   submit_date:         { type: :string },
                                   matrix_single_choice_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           max_score:             { type: :integer },
                                           order_no:              { type: :integer },
                                           score:                 { type: :integer },
                                           score_of_question:     { type: :integer },
                                           title:                 { type: :string },
                                           value:                 { type: :string },
                                           matrix_single_choice_items:{
                                               type: :array,
                                               properties: {
                                                   score:             { type: :integer },
                                                   is_required:       { type: :boolean },
                                                   item_no:           { type: :integer },
                                                   question:          { type: :string },
                                                   right_answer:      { type: :string },
                                               }
                                           }
                                       }
                                   },
                                   choice_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           question:              { type: :string },
                                           order_no:              { type: :integer },
                                           answer:                { type: :string },
                                           is_required:           { type: :boolean },
                                           score:                 { type: :integer },
                                           value:                 { type: :integer },
                                           is_filled_in:          { type: :boolean },
                                           right_answer:          { type: :string },
                                       }
                                   },
                                   fill_in_the_blank_questions: {
                                       type: :array,
                                       properties: {
                                           id:                    { type: :integer },
                                           question:              { type: :string },
                                           order_no:              { type: :integer },
                                           answer:                { type: :string },
                                           is_required:           { type: :boolean },
                                           score:                 { type: :integer },
                                           value:                 { type: :integer },
                                           is_filled_in:          { type: :boolean },
                                           right_answer:          { type: :string },
                                       }
                                   },

                               }
                           },

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

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/options' do
    get '获取下拉列表' do
      tags '360评核-详情页(评核问卷)'
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

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/columns' do
    get '获取表头' do
      tags '360评核-详情页(评核问卷)'
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

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/{id}' do
    get '获取某一份文卷' do
      tags '360评核-详情页(评核问卷)'
        response '200', 'got show' do
          schema type: :object,
                 properties: {
                     data: {
                             questionnaire: {
                                 type: :object,
                                 properties: {
                                     id:                  { type: :integer },
                                     is_filled_in:        { type: :boolean },
                                     release_date:        { type: :string },
                                     submit_date:         { type: :string },
                                     matrix_single_choice_questions: {
                                         type: :array,
                                         properties: {
                                             id:                    { type: :integer },
                                             max_score:             { type: :integer },
                                             order_no:              { type: :integer },
                                             score:                 { type: :integer },
                                             score_of_question:     { type: :integer },
                                             title:                 { type: :string },
                                             value:                 { type: :string },
                                             matrix_single_choice_items:{
                                                 type: :array,
                                                 properties: {
                                                     score:             { type: :integer },
                                                     is_required:       { type: :boolean },
                                                     item_no:           { type: :integer },
                                                     question:          { type: :string },
                                                     right_answer:      { type: :string },
                                                 }
                                             }
                                         }
                                     },
                                     choice_questions: {
                                         type: :array,
                                         properties: {
                                             id:                    { type: :integer },
                                             question:              { type: :string },
                                             order_no:              { type: :integer },
                                             answer:                { type: :string },
                                             is_required:           { type: :boolean },
                                             score:                 { type: :integer },
                                             value:                 { type: :integer },
                                             is_filled_in:          { type: :boolean },
                                             right_answer:          { type: :string },
                                         }
                                     },
                                     fill_in_the_blank_questions: {
                                         type: :array,
                                         properties: {
                                             id:                    { type: :integer },
                                             question:              { type: :string },
                                             order_no:              { type: :integer },
                                             answer:                { type: :string },
                                             is_required:           { type: :boolean },
                                             score:                 { type: :integer },
                                             value:                 { type: :integer },
                                             is_filled_in:          { type: :boolean },
                                             right_answer:          { type: :string },
                                         }
                                     },

                                 }
                             },
                     }
                 }
        end
    end
  end

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/save' do
    patch '保存问卷' do
      tags '360评核-详情页(评核问卷)'
      response '200', 'got save' do
        schema type: :object,
               items: {
                   type: :object,
                   properties: {
                       success:                 { type: :boolean },
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/can_submit' do
    patch '能否提交' do
      tags '360评核-详情页(评核问卷)'
      response '200', 'got can_submit' do
        schema type: :object,
               items: {
                   type: :object,
                   properties: {
                       can_submit:                 { type: :boolean },
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/submit' do
    patch '提交问卷' do
      tags '360评核-详情页(评核问卷)'
      response '200', 'got submit' do
        schema type: :object,
               items: {
                   type: :object,
                   properties: {
                       success:                 { type: :boolean },
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisals/{appraisal_id}/appraisal_questionnaires/{id}/revise' do
    patch '修订问卷' do
      tags '360评核-详情页(评核问卷)'
      response '200', 'got revise' do
        schema type: :object,
               items: {
                   type: :object,
                   properties: {
                       success:                 { type: :boolean },
                   }
               }
        run_test!
      end
    end
  end

  path '/appraisal_records/appraisal_questionnaires/records' do
    get '全部评核问卷-展示列表' do
      tags '评核记录-全部评核问卷'
      response '200', 'got index' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           submit_date: {type: :integer},
                           appraisal:{
                               type: :object,
                               properties: {
                                   id:                    { type: :integer },
                                   appraisal_date:        { type: :string },
                                   appraisal_name:        { type: :string },
                               }
                           },
                           appraisal_participator:{
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
                                   }
                               }
                           },
                           assess_participator:{
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
                                                   personal_information: {
                                                       type: :object,
                                                       properties: {
                                                           field_values: {
                                                               type: :object,
                                                               properties: {
                                                                   place_of_birth:    { type: :string, description: '国籍' },
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
            }

      end
    end
  end

  path '/appraisal_records/appraisal_questionnaires/options' do
    get '获取下拉列表' do
      tags '评核记录-全部评核问卷'
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

  path '/appraisal_records/appraisal_questionnaires/columns' do
    get '获取表头' do
      tags '评核记录-全部评核问卷'
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

end