require 'swagger_helper'

describe 'Air Ticket API' do

  path '/profiles/index_by_department' do
    get '展示部门员工档案' do
      tags '展示部门员工档案'
      parameter name: :user_id, in: :query, type: :integer
      response '200', '展示部门员工档案' do
        schema type: :object,
               properties: {
                   data: {
                       type: :object,
                       properties: {
                           data: {
                               type: :object,
                               properties: {
                                   id: {type: :integer},
                                   chinese_name:{type: :string},
                                   date_of_employment:{type: :date},
                                   department:{type: :string},
                                   division_of_job:{type: :string},
                                   employment_status:{type: :string},
                                   empoid:{type: :integer},
                                   english_name:{type: :string},
                                   gender:{type: :integer},
                                   location:{type: :string},
                                   photo:{type: :string},
                                   position:{type: :string}

                               }
                       },
                       meta: {
                       type: :object,
                       properties: {
                           current_page: {type: :integer},
                           total_count:{type: :integer},
                           total_pages:{type: :integer}

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