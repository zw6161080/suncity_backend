require 'swagger_helper'

describe 'Training Absentees API' do

  path '/staff_feedbacks' do
    get 'Index all feedbacks' do
      tags '員工意見及投訴'
      parameter name: :locale,         in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,           in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,    in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction, in: :query, type: :string,  description: '排序方向'
      parameter name: :feedback_date,  in: :query, type: :object,  properties: { begin: { type: :string, description: '提交日期(起)，YYYY/MM/DD。' },
                                                                                 end:   { type: :string, description: '提交日期(止)，YYYY/MM/DD。' } }
      parameter name: :employee_name,  in: :query, type: :string,  description: '提交人姓名'
      parameter name: :employee_no,    in: :query, type: :string,  description: '提交人員工編號'
      parameter name: :department_id,  in: :query, type: :integer, description: '提交人部門ID'
      parameter name: :position_id,    in: :query, type: :integer, description: '提交人職位ID'
      parameter name: :feedback_track_status, in: :query, type: :string,  description: '跟進狀態，值有三种 {untracked，tracking，tracked}'
      parameter name: :feedback_tracker,      in: :query, type: :integer, description: '跟进人的ID'
      parameter name: :feedback_track_date,   in: :query, type: :object,  properties: { begin: { type: :string, description: '跟進日期(起)，YYYY/MM/DD。' },
                                                                                        end:   { type: :string, description: '跟進日期(止)，YYYY/MM/DD。' } }
      response '200', 'staff_feedbacks found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               feedback_date: { type: :string },
                               feedback_title: { type: :string },
                               feedback_content: { type: :string },
                               user_id: { type: :integer },
                               feedback_track_status: { type: :string,  description: '跟進狀態，值有三种 {untracked，tracking，tracked}' },
                               feedback_tracker_id: { type: :integer },
                               feedback_track_date: { type: :string },
                               feedback_track_content: { type: :string },
                               user: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       empoid: { type: :string },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
                                       department: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string },
                                           }
                                       },
                                       position: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string },
                                           }
                                       }
                                   }
                               },
                               feedback_tracker: {
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
                   }
               }
        run_test!
      end
    end

    post 'Create a feedback' do
      tags '員工意見及投訴'
      parameter name: :training_absentee, in: :body, schema: {
          type: :object,
          properties: {
              user_id: { type: :integer },
              feedback_date: { type: :string, description: 'YYYY/MM/DD' },
              feedback_title: { type: :string },
              feedback_content: { type: :string },
              feedback_track_status: { type: :string, descritpion: '值取三种 {untracked， tracking，tracked}' }
          },
          required: [ 'user_id', 'feedback_date', 'feedback_title', 'feedback_content', 'feedback_track_status' ]
      }
      response '200', 'training_absentee created' do
        run_test!
      end
    end
  end

  path '/staff_feedbacks/index_my_feedbacks' do
    get 'Index my feedbacks' do
      tags '員工意見及投訴'
      parameter name: :locale,         in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,           in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,    in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction, in: :query, type: :string,  description: '排序方向'
      parameter name: :feedback_date,  in: :query, type: :object,  properties: { begin: { type: :string, description: '提交日期(起)，YYYY/MM/DD。' },
                                                                                 end:   { type: :string, description: '提交日期(止)，YYYY/MM/DD。' } }
      parameter name: :feedback_track_status, in: :query, type: :string,  description: '跟進狀態，值有三种 {untracked，tracking，tracked}'
      parameter name: :feedback_tracker,      in: :query, type: :integer, description: '跟进人的ID'
      parameter name: :feedback_track_date,   in: :query, type: :object,  properties: { begin: { type: :string, description: '跟進日期(起)，YYYY/MM/DD。' },
                                                                                        end:   { type: :string, description: '跟進日期(止)，YYYY/MM/DD。' } }
      response '200', 'my staff_feedbacks found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               feedback_date: { type: :string },
                               feedback_title: { type: :string },
                               feedback_content: { type: :string },
                               user_id: { type: :integer },
                               feedback_track_status: { type: :string,  description: '跟進狀態，值有三种 {untracked，tracking，tracked}' },
                               feedback_tracker_id: { type: :integer },
                               feedback_track_date: { type: :string },
                               feedback_track_content: { type: :string },
                               user: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       empoid: { type: :string },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
                                       department: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string },
                                           }
                                       },
                                       position: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string },
                                           }
                                       }
                                   }
                               },
                               feedback_tracker: {
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
                   }
               }
        run_test!
      end
    end
  end

  path '/staff_feedbacks/export_all_feedbacks' do
    get 'Export all feedbacks' do
      tags '員工意見及投訴'
      parameter name: :locale,         in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :sort_column,    in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction, in: :query, type: :string,  description: '排序方向'
      parameter name: :feedback_date,  in: :query, type: :object,  properties: { begin: { type: :string, description: '提交日期(起)，YYYY/MM/DD。' },
                                                                                 end:   { type: :string, description: '提交日期(止)，YYYY/MM/DD。' } }
      parameter name: :employee_name,  in: :query, type: :string,  description: '提交人姓名'
      parameter name: :employee_no,    in: :query, type: :string,  description: '提交人員工編號'
      parameter name: :department_id,  in: :query, type: :integer, description: '提交人部門ID'
      parameter name: :position_id,    in: :query, type: :integer, description: '提交人職位ID'
      parameter name: :feedback_track_status, in: :query, type: :string,  description: '跟進狀態，值有三种 {untracked，tracking，tracked}'
      parameter name: :feedback_tracker,      in: :query, type: :integer, description: '跟进人的ID'
      parameter name: :feedback_track_date,   in: :query, type: :object,  properties: { begin: { type: :string, description: '跟進日期(起)，YYYY/MM/DD。' },
                                                                                        end:   { type: :string, description: '跟進日期(止)，YYYY/MM/DD。' } }
      response '200', 'staff_feedbacks exported' do
        run_test!
      end
    end
  end

  path '/staff_feedbacks/{id}' do
    patch 'Update a feedback' do
      tags '員工意見及投訴'
      parameter name: :id, in: :path, type: :integer
      parameter name: :staff_feedback, in: :body, schema: {
          type: :object,
          properties: {
              feedback_title: { type: :string },
              feedback_content: { type: :string },
              feedback_track_status: { type: :string, descritpion: '值取三种 {untracked， tracking，tracked}' }
          }
      }
      response '200', 'updated the staff_feedback' do
        run_test!
      end
    end
  end

  path '/staff_feedbacks/field_options' do
    get 'Get Options' do
      tags '員工意見及投訴'
      response '200', 'got field options' do
        schema type: :object,
               properties:{
                   data: {
                       type: :object,
                       properties: {
                           positions: {
                               type: :array,
                               items: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
                                   }
                               }
                           },
                           departments: {
                               type: :array,
                               items: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string },
                                   }
                               }
                           },
                           track_statuses: {
                               type: :array,
                               items: {
                                   type: :object,
                                   properties: {
                                       key: { type: :string },
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

end