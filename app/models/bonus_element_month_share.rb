# == Schema Information
#
# Table name: bonus_element_month_shares
#
#  id                          :integer          not null, primary key
#  location_id                 :integer
#  float_salary_month_entry_id :integer
#  bonus_element_id            :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  department_id               :integer
#  shares                      :decimal(10, 4)
#
# Indexes
#
#  index_bonus_element_month_shares_on_bonus_element_id             (bonus_element_id)
#  index_bonus_element_month_shares_on_department_id                (department_id)
#  index_bonus_element_month_shares_on_float_salary_month_entry_id  (float_salary_month_entry_id)
#  index_bonus_element_month_shares_on_location_id                  (location_id)
#
# Foreign Keys
#
#  fk_rails_34851b3b2c  (location_id => locations.id)
#  fk_rails_b6658aa0b3  (bonus_element_id => bonus_elements.id)
#  fk_rails_fc40635772  (float_salary_month_entry_id => float_salary_month_entries.id)
#

class BonusElementMonthShare < ApplicationRecord
  belongs_to :location
  belongs_to :position
  belongs_to :float_salary_month_entry
  belongs_to :bonus_element

  def self.query(params)
    query = BonusElementMonthShare.all
    [
      :location_id,
      :department_id,
      :float_salary_month_entry_id,
      :bonus_element_id
    ].each do |attr|
      query = query.where(attr => params[attr]) if params[attr]
    end
    query
  end

  def self.batch_update(updates)
    BonusElementMonthShare.update(
      updates.pluck(:id),
      updates.map { |up| ({ shares: up[:shares] }) }
    )
  end
end
