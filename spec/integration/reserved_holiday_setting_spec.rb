require 'swagger_helper'

describe 'Reserved Holiday Setting API' do

  path '/reserved_holiday_settings' do
    get '获取预留假期设置' do
      tags '预留假期设置'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :name,          type: :string, in: :query, description: '預留假期名稱'
      parameter name: :date_end,      type: :string, in: :query, description: '開始日期 yyyy/mm/dd'
      parameter name: :date_begin,    type: :string, in: :query, description: '結束日期 yyyy/mm/dd'
      parameter name: :days_count,    type: :string, in: :query, description: '假期天數'
      parameter name: :member_count,  type: :string, in: :query, description: '符合人數'
      parameter name: :creator,       type: :string, in: :query, description: '錄入人'
      parameter name: :created_at,    type: :string, in: :query, description: '錄入日期 yyyy/mm/dd'

      response '200', '请求成功' do
        schema type: :array, items: {
          type: :object,
          properties: {
            id:                   { type: :integer },
            can_destroy:          { type: :integer },
            chinese_name:         { type: :date },
            english_name:         { type: :string },
            simple_chinese_name:  { type: :string },
            date_begin:           { type: :date },
            date_end:             { type: :date },
            days_count:           { type: :integer },
            member_count:         { type: :integer },
            comment:              { type: :string },
            created_at:           { type: :string },
            creator:              { type: :object },
          }
        }
        run_test!
      end
    end

    post '创建预留假期设置' do
      tags '预留假期设置'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :params, in: :body, schema: {
        date_begin:          { type: :string },
        date_end:            { type: :string },
        chinese_name:        { type: :string, description: '假期中文繁體名稱' },
        english_name:        { type: :string, description: '假期英文名称' },
        simple_chinese_name: { type: :string, description: '假期中文簡體名稱' },
        days_count:          { type: :string, description: '假期天数' },
        comment:             { type: :string, description: '备注' },
        creator_id:          { type: :integer, description: '创建者' },
      }

      response '200', '请求成功' do
        run_test!
      end

    end

  end


  path '/reserved_holiday_setting/{id}' do
    patch '更新预留假期设置' do
      tags '预留假期设置'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id,   type: :string, in: :path, description: 'id'
      parameter name: :params, in: :body, schema: {
        date_begin:          { type: :string },
        date_end:            { type: :string },
        chinese_name:        { type: :string, description: '假期中文繁體名稱' },
        english_name:        { type: :string, description: '假期英文名称' },
        simple_chinese_name: { type: :string, description: '假期中文簡體名稱' },
        days_count:          { type: :string, description: '假期天数' },
        comment:             { type: :string, description: '备注' },
        creator_id:          { type: :integer, description: '创建者' },
      }

      response '200', '请求成功' do
        run_test!
      end

    end

    delete '删除预留假期设置' do
      tags '预留假期设置'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :id,   type: :string, in: :path, description: 'id'

      response '200', '请求成功' do
        run_test!
      end

    end
  end
end

