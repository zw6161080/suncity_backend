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

require 'test_helper'
require 'sidekiq/testing'

class AttachmentTest < ActiveSupport::TestCase
  setup do
    seaweed_webmock
    Sidekiq::Testing.inline!
  end

  test '预览文件转换测试' do
    attachment = Attachment.new
    attachment.file = fixture_file_upload('files/test.docx')
    attachment.save

    attachment.reload
    assert attachment.preview_hash
  end
end
