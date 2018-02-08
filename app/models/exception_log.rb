# == Schema Information
#
# Table name: exception_logs
#
#  id         :integer          not null, primary key
#  title      :string
#  body       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExceptionLog < ApplicationRecord
end
