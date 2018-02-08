# == Schema Information
#
# Table name: attachments
#
#  id            :integer          not null, primary key
#  seaweed_hash  :string
#  file_name     :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  preview_state :string
#  preview_hash  :string
#

require 'seaweed'

class Attachment < ApplicationRecord
  include AASM

  aasm column: 'preview_state' do
    state :waiting_for_process, initial: true
    state :converting
    state :convert_success
    state :unsupport_file_type
    state :convert_fail

    event :start_process do
      transitions from: :waiting_for_process, to: :converting
    end

    event :process_finish do
      transitions from: :converting, to: :convert_success
    end

    event :process_unsupport do
      transitions from: :converting, to: :unsupport_file_type
    end

    event :process_fail do
      transitions from: :converting, to: :convert_fail
    end
  end

  attr_accessor :file
  attr_accessor :the_seaweed_file
  validates :seaweed_hash, presence: true

  before_validation :save_to_seaweed, on: :create

  after_create :preview_process

  def preview_process
    self.start_process!

    file_type = self.class.get_file_type(file.path)

    if self.class.previewable?(file_type)
      if self.class.is_office_file?(file_type)
        ::AttachmentPrewviewConvertWorker.perform_async(self.id)
      else
        self.preview_hash = self.seaweed_hash
        self.process_finish!
      end
    else
      self.process_unsupport!
    end
    File.delete(self.file&.path) if File.exist?( self.file&.path)
  end


  def download_path
    self.seaweed_file.url
  end

  def self.download_path_with_hash(seaweed_hash)
    self.find_file_from_seaweed(seaweed_hash).url
  end

  def save_preview_file(file_path)
    self.preview_hash = self.class.save_file_to_seaweed(file_path)
  end

  def save_to_seaweed
    unless self.seaweed_hash
      self.seaweed_hash = self.class.save_file_to_seaweed(file.tempfile.path)
      self.file_name = file.original_filename
    end
  end

  def destroy
    self.delete_from_seaweed
    super
  end

  def delete_from_seaweed
    if self.seaweed_hash
      weed_file = Seaweed.find self.seaweed_hash
      weed_file.delete!
    end
  end

  def read_file
    self.seaweed_file.read
  end

  def seaweed_file
    self.the_seaweed_file ||= self.class.find_file_from_seaweed(self.seaweed_hash)
    self.the_seaweed_file
  end

  def x_accel_url
    uri_query_hash = {}
    uri_query_hash = uri_query_hash.merge({filename: self.file_name}) if self.file_name
    uri = "/internal/#{self.download_path}?#{uri_query_hash.to_query}"

    return uri
  end

  class << self
    def is_office_file?(mine_type)
      mine_type =~ /^application\/(csv|msword|(vnd\.(ms-|openxmlformats-).*))/
    end

    def is_image?(mine_type)
      mine_type =~ /^image\/(gif|jpe?g|png)/
    end

    def is_pdf?(mine_type)
      mine_type =~ /^application\/pdf/
    end

    def previewable?(mine_type)
      is_pdf?(mine_type) or is_image?(mine_type) or is_office_file?(mine_type)
    end

    def get_file_type(path)
      IO.popen(["file", "--brief", "--mime-type", path], in: :close, err: :close).read.chomp
    end

    def save_file_to_seaweed(path)
      weed_file = Seaweed.upload path
      weed_file.id
    end

    def find_file_from_seaweed(seaweed_hash)
      weed_file = Seaweed.find seaweed_hash
      weed_file
    end

    def x_accel_url_with_hash(seaweed_hash, file_name=nil)
      uri_query_hash = {}
      uri_query_hash = uri_query_hash.merge({filename: file_name}) if file_name
      uri = "/internal/#{self.download_path_with_hash(seaweed_hash)}?#{uri_query_hash.to_query}"

      return uri
    end
  end

end
