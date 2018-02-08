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

include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :attachment do
    seaweed_hash { fake_seaweed_hash }
    file { fixture_file_upload(Rails.root.join('test', 'fixtures', 'files', 'test.txt'))}
    file_name { "test.txt" }
  end
end
