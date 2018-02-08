class EmailJob < ApplicationJob
  queue_as :email

  def perform(email_type, obj_for_email, applicant_position)
    if applicant_position == nil
      Notice.try(email_type, obj_for_email).deliver
    else
      Notice.try(email_type, obj_for_email, applicant_position).deliver
    end
  end
end
