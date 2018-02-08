require 'swagger_helper'

describe 'Training Absentees API' do

  path '/training_absentees' do
    get 'Index 获取列表' do
      tags '培訓缺席記錄'
      parameter name: :locale,         in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,           in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,    in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction, in: :query, type: :string,  description: '排序方向'
      parameter name: :employee_id,    in: :query, type: :integer, description: '員工編號'
      parameter name: :employee_name,  in: :query, type: :string,  description: '員工姓名'
      parameter name: :department,     in: :query, type: :array,   items: { type: :integer, description: '部門' }
      parameter name: :position,       in: :query, type: :array,   items: { type: :integer, description: '職位' }
      parameter name: :train_name,     in: :query, type: :array,   items: { type: :string,  description: '培訓名稱' }
      parameter name: :train_number,   in: :query, type: :string,  description: '培訓編號'
      parameter name: :train_date,     in: :query, type: :object,  properties: { begin: { type: :string, description: '培訓日期(起)，YYYY/MM/DD。' },
                                                                                 end:   { type: :string, description: '培訓日期(止)，YYYY/MM/DD。' } }
      parameter name: :has_submitted_reason, in: :query, type: :boolean, description: '是否提交缺席原因'
      parameter name: :has_been_exempted,    in: :query, type: :boolean, description: '是否豁免缺席'
      parameter name: :train_class_time,     in: :query, type: :object,  properties: { begin: { type: :string, description: '缺席培訓時間(起)，YYYY/MM/DD。' },
                                                                                       end:   { type: :string, description: '缺席培訓時間(止)，YYYY/MM/DD。' } }
      parameter name: :submit_date,          in: :query, type: :object,  properties: { begin: { type: :string, description: '提交日期(起)，YYYY/MM/DD。' },
                                                                                       end:   { type: :string, description: '提交日期(止)，YYYY/MM/DD。' } }
      response '200', 'training_absentees found' do
        schema type: :object,
               properties: {
                   data: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               id: { type: :integer },
                               user_id: { type: :integer },
                               train_class_id: { type: :integer },
                               has_submitted_reason: { type: :boolean },
                               has_been_exempted: { type: :boolean },
                               absence_reason: { type: :string },
                               submit_date: { type: :string, description: '提交日期。YYYY/MM/DD hh:mm' },
                               train_date: { type: :string, description: '培訓日期。YYYY/MM/DD ~ YYYY/MM/DD' },
                               train_class_time: { type: :string, description: '缺席培訓時間。A）YYYY/MM/DD 星期三 hh:mm-hh:mm' },
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
                               train_class: {
                                   type: :object,
                                   properties: {
                                       time_begin: { type: :string },
                                       time_end: { type: :string },
                                       train_id: { type: :integer },
                                       title_id: { type: :integer },
                                       train: {
                                           type: :object,
                                           properties: {
                                               chinese_name: { type: :string },
                                               english_name: { type: :string },
                                               simple_chinese_name: { type: :string },
                                               train_number: { type: :string },
                                               train_date_begin: { type: :string },
                                               train_date_end: { type: :string }
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

    post 'Create 创建一条培训缺席记录' do
      tags '培訓缺席記錄'
      parameter name: :training_absentee, in: :body, schema: {
          type: :object,
          properties: {
              user_id: { type: :integer },
              train_class_id: { type: :integer },
              absence_reason: { type: :string },
              submit_date: { type: :string, description: 'YYYY/MM/DD hh:mm' },
          },
          required: [ 'user_id', 'train_class_id', 'absence_reason', 'submit_date' ]
      }
      response '200', 'training_absentee created' do
        let(:training_absentee) { { user_id: @user1.id,
                                    train_class_id: @train_class1.id,
                                    absence_reason: '缺席原因',
                                    submit_date: '2017/09/01 12:00' } }
        run_test!
      end
    end
  end

  path '/training_absentees/columns' do
    get 'Get columns' do
      tags '培訓缺席記錄'
      response '200', 'got columns' do
        schema type: :array,
               items: {
                   type: :object,
                   properties: {
                       key: { type: :string },
                       chinese_name: { type: :string },
                       english_name: { type: :string },
                       simple_chinese_name: { type: :string },
                       value_type: { type: :string },
                       value_format: { type: :string },
                       data_index: { type: :string },
                       search_type: { type: :string },
                       sorter: { type: :boolean },
                       options_type: { type: :string },
                       options_predefined: {
                           type: :array,
                           items: {
                               type: :object,
                               proeprties: {
                                   key: { type: :string },
                                   chinese_name: { type: :string },
                                   english_name: { type: :string },
                                   simple_chinese_name: { type: :string }
                               }
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/training_absentees/options' do
    get 'Get options' do
      tags '培訓缺席記錄'
      response '200', 'got options' do
        schema type: :object,
               properties: {
                   options_type: { type: :string },
                   options: {
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
                   options_predefined: {
                       type: :array,
                       items: {
                           type: :object,
                           properties: {
                               key: { type: :boolean },
                               chinese_name: { type: :string },
                               english_name: { type: :string },
                               simple_chinese_name: { type: :string }
                           }
                       }
                   }
               }
        run_test!
      end
    end
  end

  path '/training_absentees.xlsx' do
    get 'Export' do
      tags '培訓缺席記錄'
      parameter name: :locale,         in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :sort_column,    in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction, in: :query, type: :string,  description: '排序方向'
      parameter name: :employee_id,    in: :query, type: :integer, description: '員工編號'
      parameter name: :employee_name,  in: :query, type: :string,  description: '員工姓名'
      parameter name: :department,     in: :query, type: :array,   items: { type: :integer, description: '部門' }
      parameter name: :position,       in: :query, type: :array,   items: { type: :integer, description: '職位' }
      parameter name: :train_name,     in: :query, type: :array,   items: { type: :string,  description: '培訓名稱' }
      parameter name: :train_number,   in: :query, type: :string,  description: '培訓編號'
      parameter name: :train_date,     in: :query, type: :object,  properties: { begin: { type: :string, description: '培訓日期(起)，YYYY/MM/DD。' },
                                                                                 end:   { type: :string, description: '培訓日期(止)，YYYY/MM/DD。' } }
      parameter name: :has_submitted_reason, in: :query, type: :boolean, description: '是否提交缺席原因'
      parameter name: :has_been_exempted,    in: :query, type: :boolean, description: '是否豁免缺席'
      parameter name: :train_class_time,     in: :query, type: :object,  properties: { begin: { type: :string, description: '缺席培訓時間(起)，YYYY/MM/DD。' },
                                                                                       end:   { type: :string, description: '缺席培訓時間(止)，YYYY/MM/DD。' } }
      parameter name: :submit_date,          in: :query, type: :object,  properties: { begin: { type: :string, description: '提交日期(起)，YYYY/MM/DD。' },
                                                                                       end:   { type: :string, description: '提交日期(止)，YYYY/MM/DD。' } }
      response '200', 'training_absentees found' do
        run_test!
      end
    end
  end

  path '/training_absentees/{id}' do
    get 'Show' do
      tags '培訓缺席記錄'
      parameter name: :id, in: :path, type: :integer
      response '200', 'got the required training_absentee' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           id: { type: :integer },
                           user_id: { type: :integer },
                           train_class_id: { type: :integer },
                           has_submitted_reason: { type: :boolean },
                           has_been_exempted: { type: :boolean },
                           absence_reason: { type: :string },
                           submit_date: { type: :string, description: '提交日期。YYYY/MM/DD hh:mm' },
                           train_date: { type: :string, description: '培訓日期。YYYY/MM/DD ~ YYYY/MM/DD' },
                           train_class_time: { type: :string, description: '缺席培訓時間。A）YYYY/MM/DD 星期三 hh:mm-hh:mm' },
                           user: {
                               type: :object,
                               properties: {
                                   id: { type: :integer },
                                   empoid: { type: :string },
                                   chinese_name: { type: :string },
                                   english_name: { type: :string },
                                   simple_chinese_name: { type: :string }
                               }
                           },
                           train_class: {
                               type: :object,
                               properties: {
                                   id: { type: :integer },
                                   time_begin: { type: :string },
                                   time_end: { type: :string },
                                   train_id: { type: :integer },
                                   title_id: { type: :integer },
                                   train: {
                                       type: :object,
                                       properties: {
                                           id: { type: :integer },
                                           chinese_name: { type: :string },
                                           english_name: { type: :string },
                                           simple_chinese_name: { type: :string },
                                           train_number: { type: :string }
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
               }
        run_test!
      end
    end

    patch 'Update' do
      tags '培訓缺席記錄'
      parameter name: :id, in: :path, type: :integer
      parameter name: :training_absentee, in: :body, schema: {
          type: :object,
          properties: {
              absence_reason: { type: :string },
              has_been_exempted: { type: :boolean }
          },
          required: [ 'absence_reason' ],
          description: '当状态为未提交、而且由员工提交跟进信息时，不需要提供参数 has_been_exempted。'
      }
      response '200', 'updated the track of one training_absentee' do
        run_test!
      end
    end
  end

end