# == Schema Information
#
# Table name: job_transfers
#
#  id                           :integer          not null, primary key
#  region                       :string
#  apply_date                   :date
#  user_id                      :integer
#  transfer_type                :integer
#  transfer_type_id             :integer
#  position_start_date          :date
#  position_end_date            :date
#  apply_result                 :boolean
#  trial_expiration_date        :date
#  salary_template_id           :integer
#  new_company_id               :integer
#  new_location_id              :integer
#  new_department_id            :integer
#  new_position_id              :integer
#  new_grade                    :integer
#  new_working_category_id      :integer
#  instructions                 :string
#  original_company_id          :integer
#  original_location_id         :integer
#  original_department_id       :integer
#  original_position_id         :integer
#  original_grade               :integer
#  original_working_category_id :integer
#  inputter_id                  :integer
#  input_date                   :date
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

require 'test_helper'

class JobTransferTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
