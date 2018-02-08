# == Schema Information
#
# Table name: grant_type_details
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  add_basic_salary       :boolean
#  basic_salary_time      :integer
#  add_bonus              :boolean
#  bonus_time             :integer
#  add_attendance_bonus   :boolean
#  attendance_bonus_time  :integer
#  add_fixed_award        :boolean
#  fixed_award_mop        :decimal(15, 2)
#  annual_award_report_id :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class GrantTypeDetail < ApplicationRecord
  after_create :set_values
  validates :user_id, :annual_award_report_id, presence:  true

  def self.create_with_params(params)
    self.create(user_id: params[:user_id], add_basic_salary: params[:add_basic_salary], basic_salary_time: params[:basic_salary_time],
                add_bonus: params[:add_bonus], bonus_time: params[:bonus_time], add_attendance_bonus: params[:add_attendance_bonus],
                attendance_bonus_time: params[:attendance_bonus_time],
                fixed_award_mop: params[:fixed_award_mop], annual_award_report_id: params[:annual_award_report_id]
    )
  end

  def set_values
    if !self.add_basic_salary
      self.basic_salary_time = 0
    end
    if !self.add_bonus
      self.bonus_time = 0
    end
    if !self.add_attendance_bonus
      self.attendance_bonus_time = 0
    end
    if !self.add_fixed_award
      self.fixed_award_mop = 0
    end
    self.save
  end
end
