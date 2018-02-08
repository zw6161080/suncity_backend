require 'swagger_helper'

describe 'Attendance Month Report Items API' do

  path '/attendance_month_report_items' do

    get '获取考勤月报列表页数据' do
      tags '考勤月报'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :year_month, in: :query, type: :string, description: '筛选考勤月份（YYYY/MM)'
      parameter name: :employee_id, in: :query, type: :string, description: '筛选员工编号'
      parameter name: :employee_name, in: :query, type: :string, description: '筛选员工姓名'
      parameter name: :department, in: :query, type: :string, description: '筛选部门ID'
      parameter name: :position, in: :query, type: :string, description: '筛选职位ID'
      parameter name: :normal_overtime_hours, in: :query, description: '筛选普通加班小时数,  type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :holiday_overtime_hours, in: :query, description: '筛选假期加班小时数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :compulsion_holiday_compensation_days, in: :query, description: '筛选强制性假期补偿天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :public_holiday_compensation_days, in: :query, description: '筛选公众假期补偿天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :absenteeism_days, in: :query, description: '筛选旷工天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :immediate_leave_days, in: :query, description: '筛选即告天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_leave_days, in: :query, description: '筛选无薪假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :paid_sick_leave_days, in: :query, description: '筛选有薪病假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_marriage_leave_days, in: :query, description: '筛选无薪婚假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_compassionate_leave_days, in: :query, description: '筛选无薪恩恤假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_maternity_leave_days, in: :query, description: '筛选无薪分娩假天数,type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :paid_maternity_leave_days, in: :query, description: '筛选有薪分娩假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :pregnant_sick_leave_days, in: :query, description: '筛选怀孕病假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :occupational_injury_days, in: :query, description: '筛选工伤天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :late_0_10_min_times, in: :query, description: '筛选迟到0~10分钟次数, type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :late_10_20_min_times, in: :query, description: '筛选迟到10~20分钟次数, type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :late_20_30_min_times, in: :query, description: '筛选迟到20~30分钟次数, type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :late_30_120_min_times, in: :query, description: '筛选迟到30~120分钟天数,  type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :missing_punch_times, in: :query, description: '筛选漏打卡次数,  type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id: { type: :integer },
            user_id: { type: :integer },
            year_month: { type: :string, description: '考勤月份(YYYY/MM)' },
            normal_overtime_hours: { type: :string, description: '普通加班小时数' },
            holiday_overtime_hours:  { type: :string, description: '假期加班小时数' },
            compulsion_holiday_compensation_days: { type: :string, description: '强制性假期补偿天数' },
            public_holiday_compensation_days: { type: :string, description: '公众假期补偿天数' },
            absenteeism_days: { type: :string, description: '旷工天数' },
            immediate_leave_days: { type: :string, description: '即告天数' },
            unpaid_leave_days: { type: :string, description: '无薪假天数' },
            paid_sick_leave_days: { type: :string, description: '有薪病假天数' },
            unpaid_marriage_leave_days: { type: :string, description: '无薪婚假天数' },
            unpaid_compassionate_leave_days: { type: :string, description: '无薪恩恤假天数' },
            unpaid_maternity_leave_days: { type: :string, description: '无薪分娩假天数' },
            paid_maternity_leave_days: { type: :string, description: '有薪分娩假天数' },
            pregnant_sick_leave_days: { type: :string, description: '怀孕病假天数' },
            occupational_injury_days: { type: :string, description: '工伤天数' },
            late_0_10_min_times: { type: :integer, description: '迟到0~10分钟次数' },
            late_10_20_min_times: { type: :integer, description: '迟到10~20分钟次数' },
            late_20_30_min_times: { type: :integer, description: '迟到20~30分钟次数' },
            late_30_120_min_times: { type: :integer, description: '迟到30~120分钟次数' },
            missing_punch_times: { type: :integer, description: '漏打卡次数' },
            user: { '$ref' => '#/definitions/user' }
          }
        }
        run_test!
      end

    end  # GET
  end  #  PATH


  path '/attendance_month_report_items.xlsx' do
    get '导出考勤月报列表页数据' do
      tags '考勤月报'
      consumes 'application/json'
      produces 'application/xlsx'
      parameter name: :year_month, in: :query, type: :string, description: '筛选考勤月份（YYYY/MM)'
      parameter name: :employee_id, in: :query, type: :string, description: '筛选员工编号'
      parameter name: :employee_name, in: :query, type: :string, description: '筛选员工姓名'
      parameter name: :department, in: :query, type: :string, description: '筛选部门ID'
      parameter name: :position, in: :query, type: :string, description: '筛选职位ID'
      parameter name: :normal_overtime_hours, in: :query, description: '筛选普通加班小时数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :holiday_overtime_hours, in: :query, description: '筛选假期加班小时数, type: :object, properties: {
         begin: { type: :string },
         end: { type: :string }
       }'
      parameter name: :compulsion_holiday_compensation_days, in: :query, description: '筛选强制性假期补偿天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :public_holiday_compensation_days, in: :query, description: '筛选公众假期补偿天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :absenteeism_days, in: :query, description: '筛选旷工天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :immediate_leave_days, in: :query, description: '筛选即告天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_leave_days, in: :query, description: '筛选无薪假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :paid_sick_leave_days, in: :query, description: '筛选有薪病假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_marriage_leave_days, in: :query, description: '筛选无薪婚假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_compassionate_leave_days, in: :query, description: '筛选无薪恩恤假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :unpaid_maternity_leave_days, in: :query, description: '筛选无薪分娩假天数,type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :paid_maternity_leave_days, in: :query, description: '筛选有薪分娩假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :pregnant_sick_leave_days, in: :query, description: '筛选怀孕病假天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :occupational_injury_days, in: :query, description: '筛选工伤天数, type: :object, properties: {
        begin: { type: :string },
        end: { type: :string }
      }'
      parameter name: :late_0_10_min_times, in: :query, description: '筛选迟到0~10分钟次数, type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :late_10_20_min_times, in: :query, description: '筛选迟到10~20分钟次数, type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :late_20_30_min_times, in: :query, description: '筛选迟到20~30分钟次数, type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :late_30_120_min_times, in: :query, description: '筛选迟到30~120分钟天数,  type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'
      parameter name: :missing_punch_times, in: :query, description: '筛选漏打卡次数,  type: :object, properties: {
        begin: { type: :integer },
        end: { type: :integer }
      }'

      response '200', '请求成功' do
        run_test!
      end
    end  # GET
  end  # PATH

  path '/attendance_month_report_items/columns' do
    get '获取报表所有的列数据' do
      tags '考勤月报'
      consumes 'application/json'
      produces 'application/json'

      response '200', '请求成功' do
        schema type: :array, items: { '$ref' => '#/definitions/statement_column' }
        run_test!
      end
    end  # GET
  end  # PATH

  path '/attendance_month_report_items/options' do
    get '获取报表所有筛选项数据' do
      tags '考勤月报'
      consumes 'application/json'
      produces 'application/json'
      response '200', '请求成功' do
        run_test!
      end
    end  # GET
  end  # PATH

end