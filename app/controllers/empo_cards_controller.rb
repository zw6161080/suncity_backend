class EmpoCardsController < ApplicationController
  def index
    cards = search_query
    response_json cards
  end

  def create
    params.require(:approved_job_id)
    params.require(:approved_job_number)
    job = ApprovedJob.find(params[:approved_job_id])
    cards = job.empo_cards.where(approved_job_number: params[:approved_job_number])
    card = nil

    if cards.count == 0
      ActiveRecord::Base.transaction do
        paramsn = params.permit(:approved_job_number,
                                :allocation_valid_date,
                                :approved_number,
                                :approval_valid_date,
                                :approved_job_id)

        card = EmpoCard.create(paramsn)

        card.update(operator_name: current_user.chinese_name,
                    approved_job_name: job.approved_job_name,
                    report_salary_count: job.report_salary_count,
                    report_salary_unit: job.report_salary_unit,
                    used_number: CardProfile.where(approved_job_name: paramsn[:approved_job_name],
                                                   approved_job_number:   paramsn[:approved_job_number],
                                                   status:'fingermold').count)
        job.update(number: job.empo_cards.count)

      end

    end
    response_json id: card.id if card != nil
  end
  def update
    params.require(:id)
    paramsn = params.permit(:approved_job_number,
                            :allocation_valid_date,
                            :approved_number,
                            :approval_valid_date,
                            )
    card = EmpoCard.find( params[:id])
    card.update(paramsn)
    card.update(operator_name: current_user.chinese_name,
                used_number: CardProfile.where(approved_job_name: card.approved_job_name,
                                               approved_job_number: card.approved_job_number,
                                               status: 'fingermold').count)
    response_json
  end

  def destroy
    params.require(:id)
    card = EmpoCard.find(params[:id])
    card.destroy
    card.approved_job.update(number: card.approved_job.empo_cards.count)
    response_json
  end

  def destroy_job_with_cards
    params.require(:id)
    job = ApprovedJob.find(params[:id])
    job.empo_cards.destroy_all
    job.destroy
    response_json
  end

  private
  def search_query
    params.require(:id)
    ApprovedJob.find(params[:id]).empo_cards.order('created_at asc')
  end
end
