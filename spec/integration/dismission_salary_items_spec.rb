require 'swagger_helper'

describe 'Dismission Salary Items API' do

  path '/dismission_salary_items' do

    get '获取离职尾期薪金报表数据' do
      tags '离职尾期薪金'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :dimission_date, in: :query, type: :string, description: '离职日期 YYYY/MM/DD'
      parameter name: :employee_id, in: :query, type: :string, description: '员工编号'
      parameter name: :employee_name, in: :query, type: :string, description: '员工姓名'
      parameter name: :company, in: :query, type: :string, description: '公司的key'
      parameter name: :department, in: :query, type: :integer, description: '部门的ID'
      parameter name: :position, in: :query, type: :integer, description: '职位的ID'
      parameter name: :grade, in: :query, type: :string, description: '职级'
      parameter name: :dimission_type, in: :query, type: :string, description: '离职类型', enum: ['resignation', 'termination']
      parameter name: :dimission_reason, in: :query, type: :string, description: '离职原因的数组'
      parameter name: :has_seniority_compensation, in: :query, type: :boolean, description: '是否有年资补偿'
      parameter name: :has_inform_period_compensation, in: :query, type: :boolean, description: '是否有离职通知期'
      parameter name: :base_salary_hkd, in: :query, type: :string, description: '底薪'
      parameter name: :benefits_hkd, in: :query, type: :string, description: '津贴'
      parameter name: :annual_incentive_hkd, in: :query, type: :string, description: '勤工'
      parameter name: :housing_benefits_hkd, in: :query, type: :string, description: '房屋津贴'
      parameter name: :seniority_compensation_hkd, in: :query, type: :string, description: '年资补偿'
      parameter name: :dismission_annual_holiday_compensation_hkd, in: :query, type: :string, description: '剩余年假补偿'
      parameter name: :dismission_inform_period_compensation_hkd, in: :query, type: :string, description: '离职通知期补偿'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            user_id: { type: :integer },
            base_salary_hkd: { type: :string, description: '底薪' },
            benefits_hkd: { type: :string, description: '津贴' },
            annual_incentive_hkd: { type: :string, description: '勤工' },
            housing_benefits_hkd: { type: :string, description: '房屋津贴' },
            seniority_compensation_hkd: { type: :string, description: '年资补偿' },
            dismission_annual_holiday_compensation_hkd: { type: :string, description: '离职年假补偿' },
            dismission_inform_period_compensation_hkd: { type: :string, description: '离职通知期补偿' },
            has_seniority_compensation: { type: :boolean, description: '是否有年资补偿' },
            has_inform_period_compensation: { type: :boolean, description: '是否有离职通知期补偿' },
            approved:  { type: :boolean, description: '是否已经审批' },
            user: { '$ref' => '#/definitions/user' },
            dimission: { '$ref' => '#/definitions/dimission' },
          }
        }
        run_test!
      end
    end
  end

  path '/dismission_salary_items.xlsx' do

    get '导出离职尾期薪金excel' do
      tags '离职尾期薪金'
      consumes 'application/json'
      produces 'application/xlsx'
      parameter name: :dimission_date, in: :query, type: :string, description: '离职日期 YYYY/MM/DD'
      parameter name: :employee_id, in: :query, type: :string, description: '员工编号'
      parameter name: :employee_name, in: :query, type: :string, description: '员工姓名'
      parameter name: :company, in: :query, type: :string, description: '公司的key'
      parameter name: :department, in: :query, type: :integer, description: '部门的ID'
      parameter name: :position, in: :query, type: :integer, description: '职位的ID'
      parameter name: :grade, in: :query, type: :string, description: '职级'
      parameter name: :dimission_type, in: :query, type: :string, description: '离职类型', enum: ['resignation', 'termination']
      parameter name: :dimission_reason, in: :query, type: :string, description: '离职原因的数组'
      parameter name: :has_seniority_compensation, in: :query, type: :boolean, description: '是否有年资补偿'
      parameter name: :has_inform_period_compensation, in: :query, type: :boolean, description: '是否有离职通知期'
      parameter name: :base_salary_hkd, in: :query, type: :string, description: '底薪'
      parameter name: :benefits_hkd, in: :query, type: :string, description: '津贴'
      parameter name: :annual_incentive_hkd, in: :query, type: :string, description: '勤工'
      parameter name: :housing_benefits_hkd, in: :query, type: :string, description: '房屋津贴'
      parameter name: :seniority_compensation_hkd, in: :query, type: :string, description: '年资补偿'
      parameter name: :dismission_annual_holiday_compensation_hkd, in: :query, type: :string, description: '剩余年假补偿'
      parameter name: :dismission_inform_period_compensation_hkd, in: :query, type: :string, description: '离职通知期补偿'

      response '200', '请求成功' do
        run_test!
      end
    end

  end

  path '/dismission_salary_items/columns' do
    get '获取报表所有的列数据' do
      tags '离职尾期薪金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { '$ref' => '#/definitions/statement_column' }
        run_test!
      end
    end  # GET
  end

  path '/dismission_salary_items/options' do
    get '获取报表所有筛选项数据' do
      tags '离职尾期薪金'
      consumes 'application/json'
      produces 'application/json'
      response '200', '请求成功' do
        run_test!
      end
    end  # GET
  end

  path '/dismission_salary_items/{id}/approve' do
    patch '审批离职尾期薪金' do
      tags '离职尾期薪金'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '离职尾期薪金条目的ID'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

end