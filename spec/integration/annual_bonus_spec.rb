require 'swagger_helper'

describe 'Annual Bonus API' do

  path '/annual_bonus_events' do
    get '获取年度奖金列表' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer, description: '年度奖金事件ID' },
            chinese_name: { type: :string, description: '年度奖金繁体中文名' },
            english_name: { type: :string, description: '年度奖金英文名' },
            simple_chinese_name: { type: :string, description: '年度奖金简体中文名' },
            begin_date: { type: :date, description: '年度奖金起始日期' },
            ende_date: { type: :date, description: '年度奖金结束日期' },
            annual_incentive_payment_hkd: { type: :string, description: '全年勤工奖HKD数额' },
            year_end_bonus_rule: { type: :string, description: '花红发放规则的key', enum: [ 'by_salary', 'fixed_amount' ] },
            year_end_bonus_mop: { type: :string, description: '花红MOP数额' },
            settlement_type: { type: :string, description: '发放方式的key', enum: [ 'salary_settlement', 'separate_settlement' ] },
            settlement_date: { type: :date, description: '发放日期' },
            grant_status: { type: :string, description: '审批状态', enum: [ 'not_granted', 'granted' ] }
          }
        }
        run_test!
      end
    end
  end

  path '/annual_bonus_events/{id}/' do
    get '获取某一个年度奖金报表' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '年度奖金条目的ID'

      response '200', '请求成功' do
        schema type: :object, properties: {
          id: { type: :integer, description: '年度奖金事件ID' },
          chinese_name: { type: :string, description: '年度奖金繁体中文名' },
          english_name: { type: :string, description: '年度奖金英文名' },
          simple_chinese_name: { type: :string, description: '年度奖金简体中文名' },
          begin_date: { type: :date, description: '年度奖金起始日期' },
          ende_date: { type: :date, description: '年度奖金结束日期' },
          annual_incentive_payment_hkd: { type: :string, description: '全年勤工奖HKD数额' },
          year_end_bonus_rule: { type: :string, description: '花红发放规则的key', enum: [ 'by_salary', 'fixed_amount' ] },
          year_end_bonus_mop: { type: :string, description: '花红MOP数额' },
          settlement_type: { type: :string, description: '发放方式的key', enum: [ 'salary_settlement', 'separate_settlement' ] },
          settlement_date: { type: :date, description: '发放日期' },
          grant_status: { type: :string, description: '审批状态', enum: [ 'not_granted', 'granted' ] }
        }
        run_test!
      end
    end

    delete '删除年度奖金报表' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '年度奖金条目的ID'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

  path '/annual_bonus_events/{id}/grant' do
    patch '审批年度奖金报表' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id, type: :integer, in: :path, description: '年度奖金条目的ID'

      response '200', '请求成功' do
        run_test!
      end
    end
  end

  path '/annual_bonus_items' do
    get '获取年度奖金报表数据' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer, description: '年度奖金条目ID' },
            has_annual_incentive_payment: { type: :boolean, description: '是否有全年勤工奖' },
            has_double_pay: { type: :boolean, description: '是否有双粮' },
            double_pay_mop: { type: :string, description: '双粮MOP数额' },
            has_year_end_bonus: { type: :boolean, description: '是否有花红' },
            year_end_bonus_mop: { type: :string, description: '花红MOP金额' },
            user: { '$ref' => '#/definitions/user' }
          }
        }
        run_test!
      end
    end
  end

  path '/annual_bonus_items/columns' do
    get '获取年度奖金报表的列' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { '$ref' => '#/definitions/statement_column' }
        run_test!
      end
    end
  end

  path '/annual_bonus_items/options' do
    get '获取年度奖金报表下拉筛选项' do
      tags '年度奖金'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        run_test!
      end
    end
  end
end