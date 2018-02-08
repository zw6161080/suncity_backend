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

require 'test_helper'

class AgreementTest < ActiveSupport::TestCase

  test 'manila_files and macau_files exist' do
    Agreement.manila_files.each do |file|
      path = Agreement.input_path('manila', file.first)
      assert File.exist?(path)
    end

    Agreement.macau_files do |file|
      path = Agreement.input_path('macau', file.first)
      assert File.exist?(path)
    end
  end

end
