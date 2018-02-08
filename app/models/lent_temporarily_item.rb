# == Schema Information
#
# Table name: lent_temporarily_items
#
#  id                        :integer          not null, primary key
#  region                    :string
#  user_id                   :integer
#  lent_temporarily_apply_id :integer
#  lent_date                 :date
#  return_date               :date
#  lent_location_id          :integer
#  comment                   :text
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  lent_salary_calculation   :string
#  return_salary_calculation :string
#
# Indexes
#
#  index_lent_temporarily_items_on_lent_location_id           (lent_location_id)
#  index_lent_temporarily_items_on_lent_temporarily_apply_id  (lent_temporarily_apply_id)
#  index_lent_temporarily_items_on_user_id                    (user_id)
#

class LentTemporarilyItem < ApplicationRecord
  belongs_to :user
  belongs_to :lent_temporarily_apply
  belongs_to :lent_location, class_name: 'Location', foreign_key: :lent_location_id


end
