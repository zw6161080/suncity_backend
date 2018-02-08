class ApplicantPositionsController < ApplicationController
  def show
    applicant_position = ApplicantPosition.find(params[:id])
    response_json applicant_position.as_json(
      methods: [:logs_count, :interviews_count, :contracts_count],
      include: [:department, :position]
    )
  end

  def update_status


    applicant_position = ApplicantPosition.find(params[:id])
    applicant_position.assign_attributes(params.permit(:status, :comment))
    changes = applicant_position.changes
    result = applicant_position.save

    LogService.new(:applicant_position_updated, current_user, applicant_position, changes).save_log(applicant_position) if result

    response_json result
  end

  def statuses
    statuses = ApplicantPosition.statuses
    chinese_statuses = ApplicantPosition.chinese_statuses
    english_statuses = ApplicantPosition.english_statuses
    simple_chinese_statuses = ApplicantPosition.simple_chinese_statuses

    result = statuses.reduce([]) do |statuses_res, status|
      statuses_res.push({
        key: status.first,
        chinese_name: chinese_statuses.fetch(status.first.to_sym),
        english_name: english_statuses.fetch(status.first.to_sym),
        simple_chinese_name: simple_chinese_statuses.fetch(status.first.to_sym)
      })
      statuses_res
    end

    response_json result
  end

  def summary
    result = {
      applicant_sum: ApplicantPosition.count,
      choose_needed: ApplicantPosition.choose_needed.count,
      choose_failed: ApplicantPosition.interview_failed_count,
      contract_needed: ApplicantPosition.contract_needed.count,
      entry_needed: ApplicantPosition.entry_needed.count
    }

    response_json result
  end

  def create_empoid
    applicant_position = ApplicantPosition.find(params[:id])
    response_json applicant_position.create_profile
  end
end
