require 'swagger_helper'

describe 'New Employee Profile API' do

  path '/card_profiles/current_card_profile_by_user' do
    get 'Create a work_permit' do
    tags '工作签证信息'
    parameter name: :user_id, in: :query, type: :integer

    response '200', 'Create a work_permit' do
      schema type: :object,
             properties: {
                 data: {
                     type: :array,
                     items: {
                         type: :object,
                         properties: {
                                      id:                         { type: :integer },
                                      approved_job_name:          { type: :string },
                                      approved_job_number:        { type: :string },
                                      report_salary_count:        { type: :integer },
                                      date_to_get_card:           { type: :date },
                                      date_to_stamp:              { type: :date },
                                      card_valid_date:            { type: :date },
                                      date_to_submit_fingermold:  { type: :date },
                                      new_or_renew:               { type: :string }
                         }
                     }
                 }
             }
                         end
                     end
                 end
             end
