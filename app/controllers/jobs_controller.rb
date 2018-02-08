class JobsController < ApplicationController

  def enabled
    jobs = Job.includes(:department, :position)
              .where(status: 'enabled')
              .by_region(params[:region])

    response_json jobs.as_json(methods: [:key, :chinese_name, :english_name])
  end

  def jobs_with_pending
    jobs = Job.by_region(params[:region])
    unless params[:with_disabled]
      jobs = jobs.where(status: :enabled)
    end
    pending_job = {
      id: 'pending',
      key: 'pending',
      chinese_name: '待定',
      english_name: 'Pending',
      simple_chinese_name: '待定'
    }

    response_json jobs.as_json(methods: [:key, :chinese_name, :english_name, :simple_chinese_name]).unshift(pending_job)
  end

  def index
    authorize Job
    jobs_query = Job.all


    if params[:region]
      jobs_query = jobs_query
                  .where('jobs.region = ?', params[:region])
    end

    if params[:department_id]
      jobs_query = jobs_query
                  .where('jobs.department_id = ?', params[:department_id].to_i)
    end

    if params[:grade]
      jobs_query = jobs_query
                  .where('jobs.grade = ?', params[:grade])
    end

    if params[:status]
      jobs_query = jobs_query
                  .where(status: params[:status])
    end

    jobs_query = jobs_query.order(status: :asc, created_at: :desc)
    if params[:pagination] != 'false'
      jobs_query = jobs_query.page(params[:page]).per(10)
    end

    result = jobs_query.as_json(methods: [:key, :chinese_name, :english_name, :position_profiles_count], include: [:department, :position])

    meta = {}

    if params[:pagination] != 'false'
      meta = {
        total_count: jobs_query.total_count,
        current_page: jobs_query.current_page,
        total_pages: jobs_query.total_pages
      }
    end

    response_json result, meta: meta
  end

  def create
    authorize Job
    job = Job.create(job_params)

    response_json
  end

  def update
    authorize Job
    job = Job.find(params[:id])
    job.update!(job_params)

    response_json
  end

  def show
    job = Job.find(params[:id]).as_json(include: [ :department, :position ])
    response_json job
  end

  def destroy
    job = Job.find(params[:id])
    job.delete

    response_json
  end

  def statuses
    response_json Job.statuses
  end

  def statistics
    response_json Job.statistics(params[:region])
  end

  private
  def job_params
    params.require(:job).permit(
      :region,
      :department_id,
      :position_id,
      :superior_email,
      :grade,
      :number,
      :chinese_range,
      :english_range,
      :chinese_skill,
      :english_skill,
      :chinese_education,
      :english_education
    )
  end
end
