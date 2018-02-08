# == Schema Information
#
# Table name: options
#
#  id                 :integer          not null, primary key
#  choice_question_id :integer
#  option_no          :integer
#  description        :string
#  supplement         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  has_supplement     :boolean
#
# Indexes
#
#  index_options_on_choice_question_id  (choice_question_id)
#

class Option < ApplicationRecord
  belongs_to :choice_question
  has_many :attend_attachments, as: :attachable, dependent: :destroy

  def self.create_params
    [:option_no, :description, :supplement, :has_supplement]
  end
end
