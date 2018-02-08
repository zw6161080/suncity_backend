class ProfileAttachmentTypesController < ApplicationController
  include AttachmentTypeActions

  private

  def model
    ProfileAttachmentType
  end
  
end
