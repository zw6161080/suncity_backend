require 'swagger_helper'

describe 'Client Comments API' do

  path '/client_comments' do
    post 'Create a client_comment' do
      tags '客戶意見'
      parameter name: :client_comment, in: :body, schema: {
          type: :object,
          properties: {
              user_id:             { type: :integer },
              client_account:      { type: :string },
              client_name:         { type: :string },
              client_fill_in_date: { type: :string, description: 'YYYY/MM/DD' },
              client_phone:        { type: :string },
              client_account_date: { type: :string, description: 'YYYY/MM/DD' },
              involving_staff:     { type: :string },
              event_time_start:    { type: :string, description: 'YYYY/MM/DD hh:mm' },
              event_time_end:      { type: :string, description: 'YYYY/MM/DD hh:mm' },
              event_place:         { type: :string },
              track_content:       { type: :string }
          },
          required: ['user_id','client_account','client_name','client_fill_in_date','client_phone','client_account_date']
      }
      response '200', 'created a client_comment' do
        run_test!
      end
    end

    get 'Index client_comments' do
      tags '客戶意見'
      parameter name: :locale,              in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,         in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,      in: :query, type: :string,  description: '排序方向'
      parameter name: :user_id,             in: :query, type: :integer, description: 'user_id，用于区分：客户意见 我的客户意见'
      parameter name: :employee_name,       in: :query, type: :string,  description: '跟進員工姓名'
      parameter name: :employee_id,         in: :query, type: :string,  description: '跟進員工編號'
      parameter name: :department,          in: :query, type: :array,   items: { type: :integer, description: '部門' }
      parameter name: :position,            in: :query, type: :array,   items: { type: :integer, description: '職位' }
      parameter name: :client_fill_in_date, in: :query, type: :object,  properties: { begin: { type: :string, description: '客戶填寫日期(起)，YYYY/MM/DD。' },
                                                                                      end:   { type: :string, description: '客戶填寫日期(止)，YYYY/MM/DD。' } }
      parameter name: :client_account,      in: :query, type: :string,  description: '客戶戶口'
      parameter name: :client_name,         in: :query, type: :string,  description: '客戶姓名'
      parameter name: :last_tracker,        in: :query, type: :string,  description: '最新跟進人'
      parameter name: :last_track_date,     in: :query, type: :object,  properties: { begin: { type: :string, description: '最新跟進日期(起)，YYYY/MM/DD。' },
                                                                                      end:   { type: :string, description: '最新跟進日期(止)，YYYY/MM/DD。' } }
      response '200', 'client_comments found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id:                  { type: :integer },
                               user_id:             { type: :integer },
                               client_account:      { type: :string, description: '客戶戶口' },
                               client_name:         { type: :string, description: '客戶姓名' },
                               client_fill_in_date: { type: :string, description: '客戶填寫日期' },
                               client_phone:        { type: :string },
                               client_account_date: { type: :string },
                               involving_staff:     { type: :string },
                               event_time_start:    { type: :string },
                               event_time_end:      { type: :string },
                               event_place:         { type: :string },
                               last_tracker_id:     { type: :integer },
                               last_track_date:     { type: :string, description: '最新跟進日期' },
                               last_track_content:  { type: :string, description: '最新跟進內容' },
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
                                               simple_chinese_name: { type: :string }
                                           }
                                       },
                                       position: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string }
                                           }
                                       }
                                   }
                               },
                               last_tracker: {
                                   type: :object,
                                   description: '最新跟進人',
                                   properties: {
                                       id: { type: :integer },
                                       empoid: { type: :string },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string }
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

  path '/client_comments/columns' do
    get 'Get columns' do
      tags '客戶意見'
      response '200', 'got columns' do
        schema type: :array,
               items: {
                   type: :object,
                   properteis: {
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

  path '/client_comments/options' do
    get 'Get options' do
      tags '客戶意見'
      response '200', 'got options' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           department: {
                               type: :array,
                               items: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
                           position: {
                               type: :array,
                               items: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       chinese_name: { type: :string },
                                       english_name: { type: :string },
                                       simple_chinese_name: { type: :string }
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

  path '/client_comments/export' do
    get 'Export' do
      tags '客戶意見'
      parameter name: :locale,              in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :sort_column,         in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,      in: :query, type: :string,  description: '排序方向'
      parameter name: :user_id,             in: :query, type: :integer, description: 'user_id，用于区分：客户意见 我的客户意见'
      parameter name: :employee_name,       in: :query, type: :string,  description: '跟進員工姓名'
      parameter name: :employee_id,         in: :query, type: :string,  description: '跟進員工編號'
      parameter name: :department,          in: :query, type: :array,   items: { type: :integer, description: '部門' }
      parameter name: :position,            in: :query, type: :array,   items: { type: :integer, description: '職位' }
      parameter name: :client_fill_in_date, in: :query, type: :object,  properties: { begin: { type: :string, description: '客戶填寫日期(起)，YYYY/MM/DD。' },
                                                                                      end:   { type: :string, description: '客戶填寫日期(止)，YYYY/MM/DD。' } }
      parameter name: :client_account,      in: :query, type: :string,  description: '客戶戶口'
      parameter name: :client_name,         in: :query, type: :string,  description: '客戶姓名'
      parameter name: :last_tracker,        in: :query, type: :string,  description: '最新跟進人'
      parameter name: :last_track_date,     in: :query, type: :object,  properties: { begin: { type: :string, description: '最新跟進日期(起)，YYYY/MM/DD。' },
                                                                                      end:   { type: :string, description: '最新跟進日期(止)，YYYY/MM/DD。' } }
      response '200', 'got exported' do
        run_test!
      end
    end
  end

  path '/client_comments/{id}' do
    get 'Show a client_comment' do
      tags '客戶意見'
      parameter name: :id, in: :path, type: :integer
      response '200', 'got a client_comment' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           query: {
                               type: :object,
                               properties: {
                                   id:                  { type: :integer },
                                   user_id:             { type: :integer },
                                   client_account:      { type: :string, description: '客戶戶口' },
                                   client_name:         { type: :string, description: '客戶姓名' },
                                   client_fill_in_date: { type: :string, description: '客戶填寫日期' },
                                   client_phone:        { type: :string, description: '客戶聯絡電話' },
                                   client_account_date: { type: :string, description: '客戶開戶日期' },
                                   involving_staff:     { type: :string, description: '涉及員工' },
                                   event_time_start:    { type: :string, description: '事件發生時間(起)' },
                                   event_time_end:      { type: :string, description: '事件發生時間(止)' },
                                   event_place:         { type: :string, description: '事件發生地點' },
                                   last_tracker_id:     { type: :integer },
                                   last_track_date:     { type: :string, description: '最新跟進日期' },
                                   last_track_content:  { type: :string, description: '最新跟進內容' },
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
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           position: {
                                               type: :object,
                                               properties: {
                                                   id: { type: :integer },
                                                   chinese_name: { type: :string },
                                                   english_name: { type: :string },
                                                   simple_chinese_name: { type: :string }
                                               }
                                           },
                                           location: {
                                               type: :object,
                                               properties: {
                                                   id: { type: :integer },
                                                   chinese_name: { type: :string },
                                                   english_name: { type: :string },
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
                                                                           mobile_number: { type: :string, description: '手提電話' }
                                                                       }
                                                                   }
                                                               }
                                                           },
                                                           position_information: {
                                                               type: :object,
                                                               properties: {
                                                                   field_values: {
                                                                       type: :object,
                                                                       properties: {
                                                                           date_of_employment: { type: :string, description: '入職日期' }
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
                           tracks: {
                               type: :array,
                               items: {
                                   type: :object,
                                   properties: {
                                       id: { type: :integer },
                                       content: { type: :string },
                                       user_id: { type: :integer },
                                       track_date: { type: :string },
                                       client_comment_id: { type: :integer },
                                       user: {
                                           type: :object,
                                           properties: {
                                               id: { type: :integer },
                                               empoid: { type: :string },
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string }
                                           }
                                       }
                                   }
                               }
                           }
                       }
                   }
               }
        run_test!
      end
    end

    patch 'Update a client_comment' do
      tags '客戶意見'
      parameter name: :id, in: :path, type: :integer
      parameter name: :client_comment, in: :body, schema: {
          client_account:      { type: :string },
          client_name:         { type: :string },
          client_fill_in_date: { type: :string, description: 'YYYY/MM/DD' },
          client_phone:        { type: :string },
          client_account_date: { type: :string, description: 'YYYY/MM/DD' },
          involving_staff:     { type: :string },
          event_time_start:    { type: :string, description: 'YYYY/MM/DD hh:mm' },
          event_time_end:      { type: :string, description: 'YYYY/MM/DD hh:mm' },
          event_place:         { type: :string }
      }
      response '200', 'updated a client_comment' do
        run_test!
      end
    end
  end

  path '/client_comments/show_tracker' do
    get 'Show tracker before creating a client_comment' do
      tags '客戶意見'
      parameter name: :user_id, in: :query, type: :integer
      response '200', 'got the information of the tracker' do
        schema type: :object,
               properties: {
                   data: {
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
                                   simple_chinese_name: { type: :string }
                               }
                           },
                           position: {
                               type: :object,
                               properties: {
                                   id: { type: :integer },
                                   chinese_name: { type: :string },
                                   english_name: { type: :string },
                                   simple_chinese_name: { type: :string }
                               }
                           },
                           location: {
                               type: :object,
                               properties: {
                                   id: { type: :integer },
                                   chinese_name: { type: :string },
                                   english_name: { type: :string },
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
                                                           mobile_number: { type: :string, description: '手提電話' }
                                                       }
                                                   }
                                               }
                                           },
                                           position_information: {
                                               type: :object,
                                               properties: {
                                                   field_values: {
                                                       type: :object,
                                                       properties: {
                                                           date_of_employment: { type: :string, description: '入職日期' }
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
        run_test!
      end
    end
  end

  path '/client_comments/{client_comment_id}/client_comment_tracks' do
    post 'Create a client_comment_track' do
      tags '客戶意見'
      parameter name: :client_comment_id, in: :path, type: :integer
      parameter name: :client_comment_track, in: :body, schema: {
          type: :object,
          properties: {
              content: { type: :string }
          }
      }
      response '200', 'created a client_comment_track' do
        run_test!
      end
    end
  end

  path '/client_comments/{client_comment_id}/client_comment_tracks/{client_comment_track_id}' do
    get 'Show a client_comment_track' do
      tags '客戶意見'
      parameter name: :client_comment_id, in: :path, type: :integer
      parameter name: :client_comment_track_id, in: :path, type: :integer
      response '200', 'got a client_comment_track' do
        schema type: :object,
               properties: {
                   id: { type: :integer },
                   content: { type: :string },
                   user_id: { type: :integer },
                   track_date: { type: :string },
                   client_comment_id: { type: :integer },
                   user: {
                       type: :object,
                       properties: {
                           id: { type: :integer },
                           empoid: { type: :string },
                           chinese_name: { type: :string },
                           english_name: { type: :string },
                           simple_chinese_name: { type: :string }
                       }
                   }
               }
        run_test!
      end
    end

    patch 'Update a client_comment_track' do
      tags '客戶意見'
      parameter name: :client_comment_id, in: :path, type: :integer
      parameter name: :client_comment_track_id, in: :path, type: :integer
      parameter name: :content, in: :query, type: :string
      response '200', 'updated a client_comment_track' do
        run_test!
      end
    end

    delete 'Destroy a client_comment_track' do
      tags '客戶意見'
      parameter name: :client_comment_id, in: :path, type: :integer
      parameter name: :client_comment_track_id, in: :path, type: :integer
      response '200', 'deleted a client_comment_track' do
        run_test!
      end
    end
  end

end