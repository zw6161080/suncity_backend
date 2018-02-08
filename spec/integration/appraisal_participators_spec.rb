require 'swagger_helper'

describe 'Appraisal Participator API' do

  path '/appraisals/{appraisal_id}/appraisal_participators/：appraisal_participator_id/create_assessor' do
    post '评核分配 - 创建评核人' do
    tags '360评核-详情页（评核人员名单/评核分配）'
    parameter name: :appraisal_id, in: :path, type: :integer, description: '360评核id'
    parameter name: :user_ids,
              in: :query,
              type: :object,
              properties: {
                name: :assess_type, type: :string, description: '评核类别',
                name: :assessor_id, type: :integer, description: 'user_id'
              },
              description: 'user_ids'
    response '200', 'success' do
      run_test!
      end
    end
    end

  path '/appraisals/{appraisal_id}/appraisal_participators/:appraisal_participator_id/destroy_assessor' do
    post '评核分配 - 删除评核人' do
    tags '360评核-详情页（评核人员名单/评核分配）'
    parameter name: :appraisal_id, in: :path, type: :integer, description: '360评核id'
    parameter name: :appraisal_participator_id, in: :path, type: :integer, description: '评核人员id'
    parameter name: :assessor_id, in: :query, type: :integer, description: 'assessor_id'
    response '200', 'success' do
      run_test!
      end
    end
  end

  path '/appraisals/{appraisal_id}/appraisal_participators/can_add_to_participator_list' do
    get '检查员工是否可以新增至名单' do
    tags '360评核-详情页（评核人员名单/评核分配）'
    parameter name: :appraisal_id, in: :path, type: :integer, description: '360评核id'
    parameter name: :user_ids, in: :query, type: :array, items: { type: :integer }, description: 'user_ids'
    response '200', 'success' do
      run_test!
      end
    end
  end


  path '/appraisals/{appraisal_id}/appraisal_participators' do
    post '评核人员名单 - 添加员工' do
      tags '360评核-详情页（评核人员名单/评核分配）'
      parameter name: :appraisal_id, in: :path, type: :integer, description: '360评核id'
      parameter name: :user_ids, in: :query, type: :array, items: { type: :integer }
      response '200', 'created' do
        run_test!
      end
    end

    get '评核人员名单 - 列表页' do
      tags '360评核-详情页（评核人员名单/评核分配）'
      parameter name: :appraisal_id,              in: :path, type: :integer, description: '360评核id'
      parameter name: :locale,                    in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
      parameter name: :page,                      in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column,               in: :query, type: :string,  description: '排序字段'
      parameter name: :sort_direction,            in: :query, type: :string,  description: '排序方向'
      # parameter name: :by_whom, in: :query, type: :string, description: '仅当ask_for取candidates时才传此参数。取值有2种{hr，department}，前者为HR获取所有记录，后者为部门主管获取本部门记录。'
      parameter name: :empoid,                    in: :query, type: :string, description: '员工编号'
      parameter name: :employee_name,             in: :query, type: :string, description: '姓名'
      parameter name: :location,                  in: :query, type: :array,  items: { type: :integer, description: '场馆' }
      parameter name: :department,                in: :query, type: :array,  items: { type: :integer, description: '部门' }
      parameter name: :position,                  in: :query, type: :array,  items: { type: :integer, description: '职位' }
      parameter name: :grade,                     in: :query, type: :array,  items: { type: :integer, description: '职级' }
      parameter name: :division_of_job,           in: :query, type: :array,  items: { type: :string,  description: '員工歸屬類別' }
      parameter name: :date_of_employment,        in: :query, type: :object, properties: { begin: { type: :string, description: '入職日期(起)，YYYY/MM/DD。' },
                                                                                           end:   { type: :string, description: '入職日期(止)，YYYY/MM/DD。' } }
      response '200', 'got index 评核人员名单列表页' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           id:                                  { type: :integer },
                           appaisal_id:                         { type: :integer },
                           user_id:                             { type: :integer },
                           department_id:                       { type: :integer },
                           location_id:                         { type: :integer },
                           appraisal_grade:                     { type: :integer, description: '部门内层级' },
                           departmental_appraisal_group:        { type: :integer, description: '部门内分组' },
                           date_of_employment:                  { type: :string, description: '入职日期' },
                           division_of_job:                     { type: :string, description: '归属类别' },
                           assess_others:                       { type: :integer, description: '评价他人次数' },
                           appraisal_questionnaire_template_id: { type: :integer, description: '评价模板' },
                           user: {
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
                                   # profile: {
                                   #     type: :object,
                                   #     properties: {
                                   #         data: {
                                   #             type: :object,
                                   #             properties: {
                                   #                 position_information: {
                                   #                     type: :object,
                                   #                     properties: {
                                   #                         field_values: {
                                   #                             type: :object,
                                   #                             properties: {
                                   #                                 division_of_job:    { type: :string, description: '員工歸屬類別' },
                                   #                                 date_of_employment: { type: :string, description: '入職日期' }
                                   #                             }
                                   #                         }
                                   #                     }
                                   #                 }
                                   #             }
                                   #         }
                                   #     }
                                   # }
                               }
                           },
                           superior_candidates: {
                               type: :array,
                               description: '上司評核候選人',
                               items: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
                           colleague_candidates: {
                               type: :array,
                               description: '同事評核候選人',
                               items: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
                           subordinate_candidates: {
                               type: :array,
                               description: '下屬評核候選人',
                               items: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
                           superior_assessors: {
                               type: :array,
                               description: '上司評核人',
                               items: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
                           colleague_assessors: {
                               type: :array,
                               description: '同事評核人',
                               items: {
                                   type: :object,

                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
                           subordinate_assessors: {
                               type: :array,
                               description: '下屬評核人',
                               items: {
                                   type: :object,
                                   properties: {
                                       id:                  { type: :integer },
                                       chinese_name:        { type: :string },
                                       english_name:        { type: :string },
                                       simple_chinese_name: { type: :string }
                                   }
                               }
                           },
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

  #   get '评核分配 - 列表页' do
  #     tags '360评核-详情页（评核人员名单/评核分配）'
  #     parameter name: :locale,                    in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
  #     parameter name: :page,                      in: :query, type: :integer, description: '页面编号'
  #     parameter name: :sort_column,               in: :query, type: :string,  description: '排序字段'
  #     parameter name: :sort_direction,            in: :query, type: :string,  description: '排序方向'
  #     parameter name: :ask_for, in: :query, type: :string, description: '取值有2种{candidates，assessors}，前者获取【评核人员名单列表页】，后者获取【评核分配列表页】。'
  #     parameter name: :by_whom, in: :query, type: :string, description: '仅当ask_for取candidates时才传此参数。取值有2种{hr，department}，前者为HR获取所有记录，后者为部门主管获取本部门记录。'
  #     parameter name: :empoid,                 in: :query, type: :string, description: '员工编号'
  #     parameter name: :employee_name,          in: :query, type: :string, description: '姓名'
  #     parameter name: :location,               in: :query, type: :array,  items: { type: :integer, description: '场馆' }
  #     parameter name: :department,             in: :query, type: :array,  items: { type: :integer, description: '部门' }
  #     parameter name: :position,               in: :query, type: :array,  items: { type: :integer, description: '职位' }
  #     parameter name: :grade,                  in: :query, type: :array,  items: { type: :integer, description: '职级' }
  #     parameter name: :division_of_job,        in: :query, type: :array,  items: { type: :string,  description: '員工歸屬類別' }
  #     parameter name: :date_of_employment,     in: :query, type: :object, properties: { begin: { type: :string, description: '入職日期(起)，YYYY/MM/DD。' },
  #                                                                                       end:   { type: :string, description: '入職日期(止)，YYYY/MM/DD。' } }
  #     parameter name: :times_assessing_others, in: :query, type: :integer, description: '評核他人總次數'
  #     response '200', 'got index 评核分配列表页' do
  #       schema type: :object,
  #              properties: {
  #                  data: {
  #                      type: :object,
  #                      properties: {
  #                          id:                            { type: :integer },
  #                          appaisal_id:                   { type: :integer },
  #                          user_id:                       { type: :integer },
  #                          department_id:                 { type: :integer },
  #                          appraisal_grade:               { type: :integer },
  #                          times_assessing_others:        { type: :integer, description: '評核他人總次數' },
  #                          times_assessed_by_superior:    { type: :integer, description: '上司評核次數' },
  #                          times_assessed_by_colleague:   { type: :integer, description: '同事評核次數' },
  #                          times_assessed_by_subordinate: { type: :integer, description: '下屬評核次數' },
  #                          user: {
  #                              type: :object,
  #                              properties: {
  #                                  id:                  { type: :integer },
  #                                  empoid:              { type: :string },
  #                                  grade:               { type: :integer },
  #                                  chinese_name:        { type: :string },
  #                                  english_name:        { type: :string },
  #                                  simple_chinese_name: { type: :string },
  #                                  location: {
  #                                      type: :object,
  #                                      properties: {
  #                                          id:                  { type: :integer },
  #                                          chinese_name:        { type: :string },
  #                                          english_name:        { type: :string },
  #                                          simple_chinese_name: { type: :string }
  #                                      }
  #                                  },
  #                                  department: {
  #                                      type: :object,
  #                                      properties: {
  #                                          id:                  { type: :integer },
  #                                          chinese_name:        { type: :string },
  #                                          english_name:        { type: :string },
  #                                          simple_chinese_name: { type: :string }
  #                                      }
  #                                  },
  #                                  position: {
  #                                      type: :object,
  #                                      properties: {
  #                                          id:                  { type: :integer },
  #                                          chinese_name:        { type: :string },
  #                                          english_name:        { type: :string },
  #                                          simple_chinese_name: { type: :string }
  #                                      }
  #                                  },
  #                                  profile: {
  #                                      type: :object,
  #                                      properties: {
  #                                          data: {
  #                                              type: :object,
  #                                              properties: {
  #                                                  position_information: {
  #                                                      type: :object,
  #                                                      properties: {
  #                                                          field_values: {
  #                                                              type: :object,
  #                                                              properties: {
  #                                                                  division_of_job:    { type: :string, description: '員工歸屬類別' },
  #                                                                  date_of_employment: { type: :string, description: '入職日期' }
  #                                                              }
  #                                                          }
  #                                                      }
  #                                                  }
  #                                              }
  #                                          }
  #                                      }
  #                                  }
  #                              }
  #                          },
  #                          superior_assessors: {
  #                              type: :array,
  #                              items: {
  #                                  type: :object,
  #                                  description: '上司評核評核人',
  #                                  properties: {
  #                                      id:                  { type: :integer },
  #                                      chinese_name:        { type: :string },
  #                                      english_name:        { type: :string },
  #                                      simple_chinese_name: { type: :string }
  #                                  }
  #                              }
  #                          },
  #                          colleague_assessors: {
  #                              type: :array,
  #                              items: {
  #                                  type: :object,
  #                                  description: '同事評核評核人',
  #                                  properties: {
  #                                      id:                  { type: :integer },
  #                                      chinese_name:        { type: :string },
  #                                      english_name:        { type: :string },
  #                                      simple_chinese_name: { type: :string }
  #                                  }
  #                              }
  #                          },
  #                          subordinate_assessors: {
  #                              type: :array,
  #                              items: {
  #                                  type: :object,
  #                                  description: '下屬評核評核人',
  #                                  properties: {
  #                                      id:                  { type: :integer },
  #                                      chinese_name:        { type: :string },
  #                                      english_name:        { type: :string },
  #                                      simple_chinese_name: { type: :string }
  #                                  }
  #                              }
  #                          }
  #                      }
  #                  },
  #                  meta: {
  #                      type: :object,
  #                      properties: {
  #                          total_count:    { type: :integer },
  #                          current_page:   { type: :integer },
  #                          total_pages:    { type: :integer },
  #                          sort_column:    { type: :string },
  #                          sort_direction: { type: :string }
  #                      }
  #                  }
  #              }
  #       run_test!
  #     end
  #   end
  # end

  # path '/appraisal_participators/{id}' do
  #   get '评核分配 - 编辑评核人文本框' do
  #     tags '360评核-详情页（评核人员名单/评核分配）'
  #     parameter name: :id,             in: :path,  type: :integer
  #     parameter name: :assessors_type, in: :query, type: :string, description: '一个指示，指示获取上司/同事/下属评核人名单'
  #     response '200', 'showed' do
  #       schema type: :object,
  #              properties: {
  #                  data: {
  #                      id:                            { type: :integer },
  #                      appaisal_id:                   { type: :integer },
  #                      user_id:                       { type: :integer },
  #                      department_id:                 { type: :integer },
  #                      appraisal_grade:               { type: :integer },
  #                      times_assessing_others:        { type: :integer, description: '評核他人總次數' },
  #                      times_assessed_by_superior:    { type: :integer, description: '上司評核次數' },
  #                      times_assessed_by_colleague:   { type: :integer, description: '同事評核次數' },
  #                      times_assessed_by_subordinate: { type: :integer, description: '下屬評核次數' },
  #                      assessors_type:                { type: :string,  description: '评核人类别' },
  #                      user: {
  #                          type: :object,
  #                          properties: {
  #                              id:                  { type: :integer },
  #                              empoid:              { type: :string },
  #                              grade:               { type: :integer },
  #                              chinese_name:        { type: :string },
  #                              english_name:        { type: :string },
  #                              simple_chinese_name: { type: :string },
  #                              department: {
  #                                  type: :object,
  #                                  properties: {
  #                                      id:                  { type: :integer },
  #                                      chinese_name:        { type: :string },
  #                                      english_name:        { type: :string },
  #                                      simple_chinese_name: { type: :string }
  #                                  }
  #                              },
  #                              position: {
  #                                  type: :object,
  #                                  properties: {
  #                                      id:                  { type: :integer },
  #                                      chinese_name:        { type: :string },
  #                                      english_name:        { type: :string },
  #                                      simple_chinese_name: { type: :string }
  #                                  }
  #                              }
  #                          }
  #                      }
  #                  },
  #                  assessors: {
  #                      type: :array,
  #                      items: {
  #                          type: :object,
  #                          description: '評核人',
  #                          properties: {
  #                              id:                  { type: :integer },
  #                              chinese_name:        { type: :string },
  #                              english_name:        { type: :string },
  #                              simple_chinese_name: { type: :string }
  #                          }
  #                      }
  #                  }
  #              }
  #       run_test!
  #     end
  #   end

    # patch '评核分配 - 修改上司/同事/下属评核人' do
    #   tags '360评核-详情页（评核人员名单/评核分配）'
    # end

    # delete '评核人员名单 - 删除' do
    #   tags '360评核-详情页（评核人员名单/评核分配）'
    #   parameter name: :id, in: :path,  type: :integer
    #   response '200', 'deleted' do
    #     run_test!
    #   end
    # end
  end

  # path '/appraisal_participators/export' do
  #   get '评核人员名单/评核分配 - 汇出' do
  #     tags '360评核-详情页（评核人员名单/评核分配）'
  #     parameter name: :locale,                    in: :query, type: :string,  description: '语言环境，值有三种 {en，zh-CN，zh-HK}'
  #     parameter name: :page,                      in: :query, type: :integer, description: '页面编号'
  #     parameter name: :sort_column,               in: :query, type: :string,  description: '排序字段'
  #     parameter name: :sort_direction,            in: :query, type: :string,  description: '排序方向'
  #     parameter name: :ask_for, in: :query, type: :string, description: '取值有2种{candidates，assessors}，前者获取【评核人员名单列表页】，后者获取【评核分配列表页】。'
  #     parameter name: :by_whom, in: :query, type: :string, description: '仅当ask_for取candidates时才传此参数。取值有2种{hr，department}，前者为HR获取所有记录，后者为部门主管获取本部门记录。'
  #     parameter name: :empoid,                 in: :query, type: :string, description: '员工编号'
  #     parameter name: :employee_name,          in: :query, type: :string, description: '姓名'
  #     parameter name: :location,               in: :query, type: :array,  items: { type: :integer, description: '场馆' }
  #     parameter name: :department,             in: :query, type: :array,  items: { type: :integer, description: '部门' }
  #     parameter name: :position,               in: :query, type: :array,  items: { type: :integer, description: '职位' }
  #     parameter name: :grade,                  in: :query, type: :array,  items: { type: :integer, description: '职级' }
  #     parameter name: :division_of_job,        in: :query, type: :array,  items: { type: :string,  description: '員工歸屬類別' }
  #     parameter name: :date_of_employment,     in: :query, type: :object, properties: { begin: { type: :string, description: '入職日期(起)，YYYY/MM/DD。' },
  #                                                                                       end:   { type: :string, description: '入職日期(止)，YYYY/MM/DD。' } }
  #     parameter name: :times_assessing_others, in: :query, type: :integer, description: '評核他人總次數'
  #     response '200', 'exported' do
  #       run_test!
  #     end
  #   end
  # end

  path '/appraisals/{appraisal_id}/appraisal_participators/auto_assign' do
    get '评核分配 - 自动分配' do
      tags '360评核-详情页（评核人员名单/评核分配）'
      parameter name: :appraisal_id, in: :path, type: :integer, description: '360评核id'
    end
  end

  # path '/appraisal_participators/options' do
  #   get 'options' do
  #     tags '360评核-详情页（评核人员名单/评核分配）'
  #     response '200', 'got options' do
  #       schema type: :object,
  #              properties: {
  #                  location: {
  #                      type: :array,
  #                      items: {
  #                          type: :object,
  #                          properties: {
  #                              id:                  { type: :integer },
  #                              chinese_name:        { type: :string },
  #                              english_name:        { type: :string },
  #                              simple_chinese_name: { type: :string }
  #                          }
  #                      }
  #                  },
  #                  department: {
  #                      type: :array,
  #                      items: {
  #                          type: :object,
  #                          properties: {
  #                              id:                  { type: :integer },
  #                              chinese_name:        { type: :string },
  #                              english_name:        { type: :string },
  #                              simple_chinese_name: { type: :string }
  #                          }
  #                      }
  #                  },
  #                  position: {
  #                      type: :array,
  #                      items: {
  #                          type: :object,
  #                          properties: {
  #                              id:                  { type: :integer },
  #                              chinese_name:        { type: :string },
  #                              english_name:        { type: :string },
  #                              simple_chinese_name: { type: :string }
  #                          }
  #                      }
  #                  },
  #                  grade: {
  #                      type: :array,
  #                      items: {
  #                          type: :object,
  #                          properties: {
  #                              key:                 { type: :integer },
  #                              chinese_name:        { type: :integer },
  #                              english_name:        { type: :integer },
  #                              simple_chinese_name: { type: :integer }
  #                          }
  #                      }
  #                  },
  #                  division_of_job: {
  #                      type: :array,
  #                      items: {
  #                          type: :object,
  #                          properties: {
  #                              key:                 { type: :string },
  #                              chinese_name:        { type: :string },
  #                              english_name:        { type: :string },
  #                              simple_chinese_name: { type: :string }
  #                          }
  #                      }
  #                  }
  #              }
  #       run_test!
  #     end
  #   end
  # end

end