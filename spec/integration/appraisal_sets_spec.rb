require 'swagger_helper'

describe 'Appraisal Set API' do

  path '/appraisal_basic_setting' do
    get '显示 appraisal_basic_setting' do
      tags '360评核-设置页（基础设定）'
      response '200', 'showed the  appraisal_basic_setting' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     data: {
                       type: :object,
                       properties: {
                         id: {type: :integer},
                         ratio_superior: {type: :integer, description: '評核總分 上司评核占比 两位整数'},
                         ratio_subordinate: {type: :integer, description: '評核總分 下属评核占比 两位整数'},
                         ratio_collegue: {type: :integer, description: '評核總分 同事评核占比 两位整数'},
                         ratio_self: {type: :integer, description: '評核總分 自我评核占比 两位整数'},
                         ratio_others_superior: {type: :integer, description: '他人評核分数 上司評核占比'},
                         ratio_others_subordinate: {type: :integer, description: '他人評核分数 下属評核占比'},
                         ratio_others_collegue: {type: :integer, description: '他人評核分数 同事評核占比'},
                         group_A: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组A 职级'},
                         group_B: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组B 职级'},
                         group_C: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组C 职级'},
                         group_D: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组D 职级'},
                         group_E: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组E 职级'},
                         questionnaire_submit_once_only: {type: :boolean, description: '问卷提交方式只能提交一次'},
                         introduction: {type: :string, description: '评核介绍'},
                         appraisal_attachments: {
                           type: :array,
                           items: {
                             type: :object,
                             properties: {
                               id: {type: :integer, description: 'id'},
                               attachable_type: {type: :string, description: '文件类型'},
                               file_name: {type: :string, description: '文件名'},
                               created_at: {type: :string, description: ''},
                               creator_id: {type: :integer, description: ''},
                               comment: {type: :string, description: '备注'},
                               creator: {
                                 type: :object,
                                 properties: {
                                   id: {type: :integer, description: 'user_id'},
                                   chinese_name: {type: :string},
                                   english_name: {type: :string},
                                   simple_chinese_name: {type: :string}
                                 },
                                 description: '上传者'
                               }
                             }
                           },
                           description: '相关文件'
                         }
                       }
                     },
                   }
                 }
               }
        run_test!
      end
    end
  end

  path '/appraisal_basic_setting' do
    patch '修改 appraisal_basic_setting' do
      tags '360评核-设置页（基础设定）'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          ratio_superior: {type: :integer, description: '評核總分 上司评核占比 两位整数'},
          ratio_subordinate: {type: :integer, description: '評核總分 下属评核占比 两位整数'},
          ratio_collegue: {type: :integer, description: '評核總分 同事评核占比 两位整数'},
          ratio_self: {type: :integer, description: '評核總分 自我评核占比 两位整数'},
          ratio_others_superior: {type: :integer, description: '他人評核分数 上司評核占比'},
          ratio_others_subordinate: {type: :integer, description: '他人評核分数 下属評核占比'},
          ratio_others_collegue: {type: :integer, description: '他人評核分数 同事評核占比'},
          group_A: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组A 职级'},
          group_B: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组B 职级'},
          group_C: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组C 职级'},
          group_D: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组D 职级'},
          group_E: {type: :array, items: {type: :integer, description: '职级'}, description: '评核人员分组E 职级'},
          questionnaire_submit_once_only: {type: :boolean, description: '问卷提交方式只能提交一次'},
          introduction: {type: :string, description: '评核介绍'}
        }
      }
      response '200', 'updated appraisal_basic_setting' do
        run_test!
      end
    end
  end

  path '/appraisal_basic_setting/attachments' do
    post 'create attachment' do
      tags '360评核-设置页（基础设定）'
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          attachment_id: {type: :integer},
          file_name: {type: :string},
          file_type: {type: :string},
          comment: {type: :text},
        }
      }
      response '200', 'created appraisal_attachment' do
        run_test!
      end
    end

    patch 'update attachment' do
      tags '360评核-设置页（基础设定）'
      parameter name: :id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          attachment_id: {type: :integer},
          file_name: {type: :string},
          file_type: {type: :string},
          comment: {type: :text},
        }
      }
      response '200', 'update appraisal_attachment' do
        run_test!
      end
    end

    delete 'delete attachment' do
      tags '360评核-设置页（基础设定）'
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete appraisal_attachment' do
        run_test!
      end
    end
  end

  path '/appraisal_department_settings' do
    get '获取列表 appraisal_set_by_departments' do
      tags '360评核-设置页（按部门设定）'
      response '200', 'got index appraisal_set_by_departments' do
        schema type: :object,
               properties: {
                 appraisal_department_settings: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: {type: :integer},
                       appraisal_basic_setting_id: {type: :integer},
                       location_id: {type: :integer},
                       department_id: {type: :integer},
                       number_of_employee: {type: :integer, description: '人数'},
                       group_A_appraisal_template_id: {type: :integer, description: 'A组360模板'},
                       group_B_appraisal_template_id: {type: :integer, description: 'A组360模板'},
                       group_C_appraisal_template_id: {type: :integer, description: 'A组360模板'},
                       group_D_appraisal_template_id: {type: :integer, description: 'A组360模板'},
                       group_E_appraisal_template_id: {type: :integer, description: 'A组360模板'},
                       group_situation: {type: :object, description: '分组情况'},
                       can_span_appraisal_grade: {type: :boolean, description: '可否跨評核層級'},
                       appraisal_mode_superior: {type: :string, description: '上司評核之模式'},
                       appraisal_mode_collegue: {type: :string, description: '同事評核之模式'},
                       appraisal_mode_subordinate: {type: :string, description: '下屬評核之模式'},
                       appraisal_times_superior: {type: :integer, description: '被上司評核次數'},
                       appraisal_times_collegue: {type: :integer, description: '被同事評核次數'},
                       appraisal_times_subordinate: {type: :integer, description: '下屬評核次數'},
                       appraisal_grade_quantity_inside: {type: :integer, description: '部門內層級數'},
                       whether_group_inside: {type: :boolean, description: '部門內可否分組'},
                       group_quantity_inside: {type: :integer, description: '部門內組數'},
                       appraisal_groups: {
                         type: :array,
                         description: '部门之分组',
                         items: {type: :string}
                       },
                       location: {
                         type: :object,
                         properties: {
                           id: {type: :integer},
                           chinese_name: {type: :string},
                           english_name: {type: :string},
                           simple_chinese_name: {type: :string}
                         },
                         description: '场馆'
                       },
                       department: {
                         type: :object,
                         properties: {
                           id: {type: :integer},
                           chinese_name: {type: :string},
                           english_name: {type: :string},
                           simple_chinese_name: {type: :string}
                         },
                         description: '部门'
                       }
                     }
                   }
                 }
               }
        run_test!
      end
    end
  end

  path '/appraisal_department_settings/{id}' do
    patch '修改一条 appraisal_set_by_department' do
      tags '360评核-设置页（按部门设定）'
      parameter name: :id, in: :path, type: :integer
      parameter name: :appraisal_set_by_department, in: :body, schema: {
        type: :object,
        properties: {
          group_A_appraisal_template_id: {type: :integer},
          group_B_appraisal_template_id: {type: :integer},
          group_C_appraisal_template_id: {type: :integer},
          group_D_appraisal_template_id: {type: :integer},
          group_E_appraisal_template_id: {type: :integer},
          can_span_appraisal_grade: {type: :boolean, description: '是否可以跨評核層級'},
          appraisal_mode_superior: {type: :string, description: '上司評核模式'},
          appraisal_mode_collegue: {type: :string, description: '同事評核模式'},
          appraisal_mode_subordinate: {type: :string, description: '下屬評核模式'},
          appraisal_times_superior: {type: :integer, description: '被上司評核次數'},
          appraisal_times_collegue: {type: :integer, description: '被同事評核次數'},
          appraisal_times_subordinate: {type: :integer, description: '下屬評核次數'},
          appraisal_grade_quantity_inside: {type: :integer, description: '部門內層級數'},
          whether_group_inside: {type: :boolean, description: '是否部門內分組'},
        }
      }
      response '200', 'updated one appraisal_set_by_department' do
        run_test!
      end
    end
  end

  path '/appraisal_department_settings/location_with_departments' do
    get '获取场馆部门数组' do
      tags '360评核-设置页（按部门设定）'
      response '200', 'get location with department' do
        run_test!
      end
    end
  end

  path '/appraisal_department_settings/batch_update' do
    patch '批量设定多条 appraisal_set_by_departments' do
      tags '360评核-设置页（按部门设定）'
      parameter name: :location_ids, in: :query, type: :array, items: {type: :integer}
      parameter name: :appraisal_set_by_department, in: :body, schema: {
        group_A_appraisal_template_id: {type: :integer},
        group_B_appraisal_template_id: {type: :integer},
        group_C_appraisal_template_id: {type: :integer},
        group_D_appraisal_template_id: {type: :integer},
        group_E_appraisal_template_id: {type: :integer},
        can_span_appraisal_grade: {type: :boolean, description: '是否可以跨評核層級'},
        appraisal_mode_superior: {type: :string, description: '上司評核模式'},
        appraisal_mode_collegue: {type: :string, description: '同事評核模式'},
        appraisal_mode_subordinate: {type: :string, description: '下屬評核模式'},
        appraisal_times_superior: {type: :integer, description: '被上司評核次數'},
        appraisal_times_collegue: {type: :integer, description: '被同事評核次數'},
        appraisal_times_subordinate: {type: :integer, description: '下屬評核次數'},
        appraisal_grade_quantity_inside: {type: :integer, description: '部門內層級數'},
      }
      response '200', 'batch updated' do
        run_test!
      end
    end
  end

  path '/appraisal_employee_settings' do
    get '获取列表 appraisal_set_by_users' do
      tags '360评核-设置页（按员工设定）'
      parameter name: :page, in: :query, type: :integer, description: '页面编号'
      parameter name: :sort_column, in: :query, type: :string, description: '排序字段'
      parameter name: :sort_direction, in: :query, type: :string, description: '排序方向'
      parameter name: :department_id, in: :query, type: :integer
      parameter name: :department_id, in: :query, type: :integer
      parameter name: :has_finished, in: :query, type: :array, items: {type: :integer, description: '是否設置完成'}
      parameter name: :employee_id, in: :query, type: :string, description: '员工编号'
      parameter name: :employee_name, in: :query, type: :string, description: '员工姓名'
      parameter name: :location, in: :query, type: :array, items: {type: :integer, description: '場館'}
      parameter name: :department, in: :query, type: :array, items: {type: :integer, description: '部門'}
      parameter name: :position, in: :query, type: :array, items: {type: :integer, description: '職位'}
      parameter name: :grade, in: :query, type: :array, items: {type: :integer, description: '職級'}
      parameter name: :division_of_job, in: :query, type: :array, items: {type: :string, description: '員工歸屬類別'}
      parameter name: :working_status, in: :query, type: :array, items: {type: :string, description: '在職狀態'}
      parameter name: :level_in_department, in: :query, type: :array, items: {type: :integer, description: '部門內層級'}
      response '200', 'got index appraisal_set_by_users' do
        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id:                              {type: :integer},
                       user_id:                         {type: :integer},
                       appraisal_group_id:              {type: :integer, description: '部门内分组id' },
                       has_finished:                    {type: :boolean, description: '是否已完成' },
                       appraisal_grade_quantity_inside: {type: :integer, description: '部门内层级数' },
                       level_in_department:             {type: :integer, description: '部门内层级' },
                       groups:                          {type: :array,   description: '部门内分组' },
                       working_status:                  {type: :string,  description: '在職狀態' },
                       division_of_job: {
                         type: :object,
                         properties: {
                           key:                     {type: :string},
                           chinese_name:            {type: :string},
                           simple_chinese_name:     {type: :string},
                           english_name:            {type: :string}
                         },
                         description: '归属类别'
                       },
                       user: {
                         type: :object,
                         properties: {
                           id:                          {type: :integer},
                           empoid:                      {type: :string},
                           chinese_name:                {type: :string},
                           english_name:                {type: :string},
                           simple_chinese_name:         {type: :string},
                           grade:                       {type: :integer},
                           location_id:                 {type: :integer},
                           department_id:               {type: :integer},
                           position_id:                 {type: :integer},
                           location: {
                             type: :object,
                             properties: {
                               id:                      {type: :integer},
                               chinese_name:            {type: :string},
                               english_name:            {type: :string},
                               simple_chinese_name:     {type: :string}
                             }
                           },
                           department: {
                             type: :object,
                             properties: {
                               id:                      {type: :integer},
                               chinese_name:            {type: :string},
                               english_name:            {type: :string},
                               simple_chinese_name:     {type: :string}
                             }
                           },
                           position: {
                             type: :object,
                             properties: {
                               id:                      {type: :integer},
                               chinese_name:            {type: :string},
                               english_name:            {type: :string},
                               simple_chinese_name:     {type: :string}
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

  path '/appraisal_employee_setting/{id}' do
    patch '修改一条 appraisal_set_by_user' do
      tags '360评核-设置页（按员工设定）'
      parameter name: :id, in: :path, type: :integer
      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          appraisal_group_id: {type: :integer},
          level_in_department: {type: :integer},
        }
      }
      response '200', 'updated one appraisal_set_by_user' do
        run_test!
      end
    end
  end

  path '/appraisal_employee_setting/side_options' do
    get '获取旁侧筛选列表' do
      tags '360评核-设置页（按员工设定）'
      response '200', 'got side_options' do
        schema type: :object,
               properties: {}
        run_test!
      end
    end
  end

  path '/appraisal_employee_settings/field_options' do
    get '获取表头筛选列表' do
      tags '360评核-设置页（按员工设定）'
      response '200', 'got header_options' do
        schema type: :object,
               properties: {
                 data: {
                   type: :object,
                   properties: {
                     has_finished: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           key: {type: :boolean}, chinese_name: {type: :string}, english_name: {type: :string}, simple_chinese_name: {type: :string}
                         }
                       }
                     },
                     location: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: {type: :integer}, chinese_name: {type: :string}, english_name: {type: :string}, simple_chinese_name: {type: :string}
                         }
                       }
                     },
                     department: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: {type: :integer}, chinese_name: {type: :string}, english_name: {type: :string}, simple_chinese_name: {type: :string}
                         }
                       }
                     },
                     position: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           id: {type: :integer}, chinese_name: {type: :string}, english_name: {type: :string}, simple_chinese_name: {type: :string}
                         }
                       }
                     },
                     grade: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           key: {type: :integer}, chinese_name: {type: :integer}, english_name: {type: :integer}, simple_chinese_name: {type: :integer}
                         }
                       }
                     },
                     division_of_job: {
                       type: :array,
                       items: {type: :string}
                     },
                     working_status: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           key: {type: :string}, chinese_name: {type: :string}, english_name: {type: :string}, simple_chinese_name: {type: :string}
                         }
                       }
                     },
                     appraisal_grade: {
                       type: :array,
                       items: {
                         type: :object,
                         properties: {
                           key: {type: :integer}, chinese_name: {type: :integer}, english_name: {type: :integer}, simple_chinese_name: {type: :integer}
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