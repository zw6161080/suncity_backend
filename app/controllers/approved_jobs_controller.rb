class ApprovedJobsController < ApplicationController
  def index
    authorize ApprovedJob
    jobs= search_query.page(params[:page]).per(10)
    option = {}
    option[:meta] = {
        total_count: jobs.total_count,
        current_page: jobs.current_page,
        total_pages: jobs.total_pages
    }
    response_json jobs, option
  end

  def create
    authorize ApprovedJob
    jobs = ApprovedJob.where(approved_job_name: params[:approved_job_name])
    job = nil
    if jobs.count == 0
      ActiveRecord::Base.transaction do
        params.require(:approved_job_name)
        params.require(:report_salary_count)
        params.require(:report_salary_unit)
        job = ApprovedJob.create(params.permit(:approved_job_name, :report_salary_count, :report_salary_unit))
      end
    end
    response_json id: job.id if job != nil
  end

  private
  def search_query
    ApprovedJob.all.order('created_at asc')
  end
end
