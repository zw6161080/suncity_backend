# == Schema Information
#
# Table name: agreements
#
#  id            :integer          not null, primary key
#  title         :string
#  attachment_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  region        :string
#
# Indexes
#
#  index_agreements_on_attachment_id  (attachment_id)
#

class ApplicantPositionAgreement < Agreement
  attr_accessor :applicant_position

  def load_data
    self.data = context
  end

  def file_name
    name = self.title.gsub(/[\x00\/\\:\*\?\"<>\|]/, '_')
    "#{name} #{Time.zone.now.strftime('%Y%m%d-%H%M%S')}.docx"
  end

  def output_file_path
    "#{Rails.root}/tmp/applicant_position_agreements/#{Time.zone.now.strftime('%Y%m%d-%H%M%S')}-#{SecureRandom.hex(8)}.docx"
  end

  def save_to_main_record(attachment)
    agreement_file = self.applicant_position.agreement_files.new
    agreement_file.attachment = attachment
    agreement_file.save
    agreement_file
  end

  def context
    ['macau', 'manila'].include?(self.region) ? 
      self.send("#{self.region}_context") :
      {}
  end

  def macau_context
    {
      title: 'test-title-macau'
    }
  end
  
  def manila_context
    {
      title: 'test-title'
    }
  end

end
