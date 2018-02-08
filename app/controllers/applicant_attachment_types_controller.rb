class ApplicantAttachmentTypesController < ApplicationController
  include AttachmentTypeActions

  private

  def model
    ProfileAttachmentType
  end

end
