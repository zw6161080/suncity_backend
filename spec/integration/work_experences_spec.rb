require 'swagger_helper'

describe 'Work Experences API' do

  path '/work_experences' do
    post '创建 work_experences' do
      tags '工作经验'
      parameter name: :params, in: :body, schema:{
          type: :object,
          properties: {
              company_organazition: {type: :string},
              former_head: {type: :string},
              job_description: {type: :string},
              work_experience_company_phone_number: {type: :integer},
              work_experience_email: {type: :string},
              work_experience_from: {type: :date},
              work_experience_position: {type: :string},
              work_experience_reason_for_leaving: {type: :string},
              work_experience_salary:{type: :integer},
              work_experience_to:{type: :date}
          }

      }
      response '200', 'showed the work_experences' do
        run_test!
      end
    end
  end

  path '/work_experences/{id}' do
    patch '修改 work_experences' do
      tags '工作经验'
      parameter name: :id, in: :path,type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              company_organazition: {type: :string},
              former_head: {type: :string},
              job_description: {type: :string},
              work_experience_company_phone_number: {type: :integer},
              work_experience_email: {type: :string},
              work_experience_from: {type: :date},
              work_experience_position: {type: :string},
              work_experience_reason_for_leaving: {type: :string},
              work_experience_salary:{type: :integer},
              work_experience_to:{type: :date}
          }
      }
      response '200', 'updated work_experences' do
        run_test!
      end
    end
  end

  path '/work_experences/index_by_user' do
    get '展示work_experences' do
      tags '工作经验'
      parameter name: :user_id, in: :query, type: :integer
      response '200', 'index work_experences' do
        schema type: :object,
               properties: {
                   id: {type: :integer},
                   company_organazition: {type: :string},
                   former_head: {type: :string},
                   job_description: {type: :string},
                   work_experience_company_phone_number: {type: :integer},
                   work_experience_email: {type: :string},
                   work_experience_from: {type: :date},
                   work_experience_position: {type: :string},
                   work_experience_reason_for_leaving: {type: :string},
                   work_experience_salary:{type: :integer},
                   work_experience_to:{type: :date}
               }
        run_test!
      end

    end
  end

  path '/work_experences/{id}' do
    delete 'delete work_experences' do
      tags '工作经验'
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete work_experences' do
        run_test!
      end
    end
  end
end