require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's confiugred to server Swagger from the same folder
  config.swagger_root = Rails.root.to_s + '/swagger'

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:to_swagger' rake task, the complete Swagger will
  # be generated at the provided relative path under swagger_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a swagger_doc tag to the
  # the root example_group in your specs, e.g. describe '...', swagger_doc: 'v2/swagger.json'
  config.swagger_docs = {
    'v1/swagger.json' => {
      swagger: '2.0',
      info: {
        title: '太阳城人事系统后端API',
        version: 'v1'
      },
      definitions: {
        user: {
          type: :object,
          properties: {
            id: { type: :integer },
            empoid: { type: :string },
            chinese_name: { type: :string },
            english_name: { type: :string },
            simple_chinese_name: { type: :string },
            position_id: { type: :integer },
            location_id: { type: :integer },
            department_id: { type: :integer },
            id_card_number: { type: :string },
            email: { type: :string },
            superior_email: { type: :string },
            company_name: { type: :string },
            employment_status: { type: :string },
            grade: { type: :string },
            department: { '$ref' => '#/definitions/department' },
            location: { '$ref' => '#/definitions/location' },
            position: { '$ref' => '#/definitions/position' }
          }
        },
        department: {
          type: :object,
          properties: {
            id: { type: :integer, description: '部门ID' },
            chinese_name: { type: :string, description: '部门中文名称' },
            english_name: { type: :string, description: '部门英文名称' },
            simple_chinese_name: { type: :string, description: '部门简体中文名称' },
            comment: { type: :string, description: '部门备注说明' },
            region_key: { type: :string, description: '部门所属地区' },
            parent_id: { type: :integer, description: '父级部门ID' },
            status: { type: :integer, description: '部门状态（0为启用，1为禁用)' },
            header_id: { type: :integer, description: '部门主管的User ID' }
          }
       },
        location: {
          type: :object,
          properties: {
            id: { type: :integer, description: '场馆ID' },
            chinese_name: { type: :string, description: '场馆中文名称' },
            english_name: { type: :string, description: '场馆英文名称' },
            simple_chinese_name: { type: :string, description: '场馆简体中文名称' },
            comment: { type: :string, description: '场馆备注说明' },
            region_key: { type: :string, description: '场馆所属地区' },
            parent_id: { type: :integer, description: '父级场馆ID' },
          }
        },
        position: {
          type: :object,
          properties: {
            id: { type: :integer, description: '职位ID' },
            chinese_name: { type: :string, description: '职位中文名称' },
            english_name: { type: :string, description: '职位英文名称' },
            simple_chinese_name: { type: :string, description: '职位简体中文名称' },
            comment: { type: :string, description: '职位备注说明' },
            region_key: { type: :string, description: '职位所属地区' },
            parent_id: { type: :integer, description: '父级职位ID' },
            status: { type: :integer, description: '职位状态（0为启用，1为禁用)' },
            number: { type: :string, description: '职位编号' },
            grade: { type: :string, description: '职级' }
          }
        },
        statement_column: {
          type: :object,
          properties: {
            key: { type: :string, description: 'Column的Key' },
            chinese_name: { type: :string, description: '表头繁体中文' },
            english_name: { type: :string, description: '表头英文' },
            simple_chinese_name: { type: :string, description: '表头简体中文' },
            value_type: { type: :string, description: '该列内的数据类型' },
            value_format: { type: :string, description: '该列内的数据格式' },
            data_index: { type: :string, description: '该列内访问数据的path' },
            search_type: { type: :string, description: '该列的搜索类型： search / screen / null' },
            sorter: { type: :boolean, description: '该列是否支持排序' },
            options_type: { type: :string, description: '该列的下拉筛选类型： null / predefined / selects / endpoint' },
            options_predefined: { type: :array, items: { type: :object, properties: {} }, description: '该列的下拉筛选项' },
            options_endpoint: { type: :string, description: '该列下拉筛选项的获取URL, 例如/departments' },
          }
        },
        dimission: {
          type: :object,
          properties: {
            id: { type: :integer, description: '离职申请ID' },
            user_id: { type: :integer, description: '离职员工User ID' },
            apply_date: { type: :date, description: '申请日期' },
            inform_date: { type: :date, description: '通知日期' },
            last_work_date: { type: :date, description: '最后工作日' },
            is_in_black_list: { type: :boolean, description: '是否进入黑名单' },
            comment: { type: :string, description: '备注' },
            last_salary_begin_date: { type: :date, description: '最后薪资起始日期' },
            last_salary_end_date: { type: :date, description: '最后薪资结束日期' },
            remaining_annual_holidays: { type: :integer, description: '剩余年假天数' },
            apply_comment: { type: :string, description: '申请备注' },
            resignation_reason: { type: :array, description: '辞职原因的KEY', items: { type: :string } },
            resignation_reason_extra: { type: :string, description: '辞职原因-其他' },
            resignation_future_plan: { type: :array, description: '辞职后去向的KEY', items: { type: :string } },
            resignation_is_inform_period_exempted: { type: :boolean, description: '是否豁免离职通知期' },
            resignation_inform_period_penalty: { type: :integer, description: '离职通知期惩罚天数' },
            resignation_is_recommanded_to_other_department: { type: :boolean, description: '是否推荐到其他部门' },
            termination_reason: { type: :array, description: '终止雇佣原因的KEY', items: { type: :string } },
            termination_reason_extra: { type: :string, description: '终止雇佣原因-其他' },
            termination_inform_period_days: { type: :integer, description: '离职通知期天数' },
            termination_is_reasonable: { type: :boolean, description: '是否合理解雇' },
            termination_compensation_extra: { type: :string, description: '解雇补偿-其他' },
            dimission_type: { type: :string, description: '离职类型', enum: [ 'resignation', 'termination' ] },
            creator_id: { type: :integer, description: '录入人ID' },
            holiday_cut_off_date: { type: :date, description: '假期结算日期' },
            resignation_certificate_languages: { type: :array, items: { type: :string }, description: '离职证明语言' },
            career_history_dimission_reason: { type: :string, description: '职位历史中离职原因' },
            career_history_dimission_comment: { type: :string, description: '职位历史中离职备注' },
            termination_compensation: { type: :integer, description: '解雇补偿天数' }
          }
        }
      }
    }
  }
end
