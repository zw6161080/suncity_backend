# == Schema Information
#
# Table name: agreement_files
#
#  id                    :integer          not null, primary key
#  agreement_id          :integer
#  applicant_position_id :integer
#  attachment_id         :integer
#  creator_id            :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  file_key              :string
#
# Indexes
#
#  index_agreement_files_on_agreement_id           (agreement_id)
#  index_agreement_files_on_applicant_position_id  (applicant_position_id)
#  index_agreement_files_on_attachment_id          (attachment_id)
#  index_agreement_files_on_creator_id             (creator_id)
#

class AgreementFile < ApplicationRecord
  belongs_to :attachment
  belongs_to :application_position
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  
end
