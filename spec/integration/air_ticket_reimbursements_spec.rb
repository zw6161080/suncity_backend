require 'swagger_helper'

describe 'Air Ticket API' do

  path '/air_ticket_reimbursements' do
    post '创建 air_ticket_reimbursement' do
      tags '机票报销'
      parameter name: :params, in: :body, schema:{
            type: :object,
            properties: {
                date_of_employment:{type: :date},
                route:{type: :string},
                ticket_price:{type: :integer},
                exchange_rate:{type: :integer},
                ticket_price_macau:{type: :integer},
                apply_date:{type: :date},
                reimbursement_date:{type: :date},
                remarks:{type: :string}
            }

        }
      response '200', 'showed the air_ticket_reimbursements' do
        run_test!
      end
    end
  end

  path '/air_ticket_reimbursements/{id}' do
    patch '修改 air_ticket_reimbursement' do
      tags '机票报销'
      parameter name: :id, in: :path,type: :integer
      parameter name: :params, in: :body, schema: {
          type: :object,
          properties: {
              date_of_employment:{type: :date},
              route:{type: :string},
              ticket_price:{type: :integer},
              exchange_rate:{type: :integer},
              ticket_price_macau:{type: :integer},
              apply_date:{type: :date},
              reimbursement_date:{type: :date},
              remarks:{type: :string}
          }
      }
      response '200', 'updated air_ticket_reimbursements' do
        run_test!
      end
    end
  end

  path '/air_ticket_reimbursements/index_by_user' do
      get '展示air_ticket_reimbursements' do
        tags '机票报销'
        parameter name: :user_id, in: :query, type: :integer
        response '200', 'index air_ticket_reimbursements' do
          schema type: :object,
                 properties: {
                                     id: {type: :integer},
                                     date_of_employment:{type: :date},
                                     route:{type: :string},
                                     ticket_price:{type: :integer},
                                     exchange_rate:{type: :integer},
                                     ticket_price_macau:{type: :integer},
                                     apply_date:{type: :date},
                                     reimbursement_date:{type: :date},
                                     remarks:{type: :string}
                                 }
          run_test!
        end

      end
  end

  path '/air_ticket_reimbursements/{id}' do
    delete 'delete air_ticket_reimbursement' do
      tags '机票报销'
      parameter name: :id, in: :path, type: :integer
      response '200', 'delete air_ticket_reimbursements' do
        run_test!
      end
    end
  end
end