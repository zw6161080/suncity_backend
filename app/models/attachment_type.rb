# == Schema Information
#
# Table name: attachment_types
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  description         :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  type                :string
#  simple_chinese_name :string
#
# Indexes
#
#  index_attachment_types_on_id_and_type  (id,type)
#

class AttachmentType < ApplicationRecord

end
