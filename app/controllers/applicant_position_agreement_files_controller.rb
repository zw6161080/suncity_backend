class ApplicantPositionAgreementFilesController < ApplicationController

  before_action :set_applicant_position, except: :file_list

  def index
    result = @applicant_position.agreement_files.as_json(include: :creator)

    response_json result
  end


  def generate
    applicant_position = ApplicantPosition.find(params[:applicant_position_id])
    data = applicant_position.agreement_file_data.merge(params[:data].to_h)
    data['current_user'] = OpenStruct.new({ "chinese_name" => current_user.chinese_name, "english_name" => current_user.english_name})
    attachment = Agreement.generate_file(params[:region], params[:file_key], data, params[:applicant_position_id])
    
    agreement_file = @applicant_position.agreement_files.new
    agreement_file.file_key = params[:file_key]
    agreement_file.attachment = attachment
    agreement_file.creator = current_user
    agreement_file.save
    agreement_file

    LogService.new(:agreement_file_created, current_user, agreement_file).save_log(@applicant_position)
    
    response_json agreement_file
  end


  def file_list
    files = Agreement.try("#{params[:region]}_files")

    response_json files
  end

  def destroy
    agreement_file = @applicant_position.agreement_files.find(params[:id])
    authorize agreement_file
    LogService.new(:agreement_file_removed, current_user, agreement_file).save_log(@applicant_position)
    agreement_file.attachment.destroy
    agreement_file.destroy

    response_json
  end

  def download

    applicant_attach = @applicant_position.agreement_files.find(params[:id])
    # headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    headers['X-Accel-Redirect'] = applicant_attach.attachment.x_accel_url
    render body: nil
  end  

  private

  def set_applicant_position
    @applicant_position = ApplicantPosition.find(params[:applicant_position_id])
  end

end
