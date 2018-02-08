# == Schema Information
#
# Table name: surplus_snapshots
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  year          :integer
#  holiday_type  :integer
#  surplus_count :integer          default(0)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class SurplusSnapshot < ApplicationRecord
  enum holiday_type: { annual_leave: 0,
                       birthday_leave: 1,
                       paid_bonus_leave: 2,
                       compensatory_leave: 3,
                       paid_sick_leave: 4,
                       unpaid_sick_leave: 5,
                       unpaid_leave: 6,
                       paid_marriage_leave: 7,
                       unpaid_marriage_leave: 8,
                       paid_compassionate_leave: 9,
                       unpaid_compassionate_leave: 10,
                       maternity_leave: 11,
                       paid_maternity_leave: 12,
                       unpaid_maternity_leave: 13,
                       immediate_leave: 14,
                       absenteeism: 15,
                       work_injury: 16,
                       unpaid_but_maintain_position: 17,
                       overtime_leave: 18,
                       pregnant_sick_leave: 19
                     }
end
