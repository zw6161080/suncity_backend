# == Schema Information
#
# Table name: matrix_single_choice_items
#
#  id                               :integer          not null, primary key
#  matrix_single_choice_question_id :integer
#  item_no                          :integer
#  question                         :text
#  score                            :integer
#  is_required                      :boolean
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  right_answer                     :integer
#  is_filled_in                     :boolean
#
# Indexes
#
#  matrix_single_choice_question_index  (matrix_single_choice_question_id)
#

class MatrixSingleChoiceItem < ApplicationRecord
  belongs_to :matrix_single_choice_question

  def self.create_params
    [:item_no, :question, :score, :right_answer, :is_required]
  end
end
