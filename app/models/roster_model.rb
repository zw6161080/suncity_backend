# == Schema Information
#
# Table name: roster_models
#
#  id            :integer          not null, primary key
#  region        :string
#  chinese_name  :string
#  department_id :integer
#  start_date    :date
#  end_date      :date
#  weeks_count   :integer
#  be_used       :boolean
#  be_user_count :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_roster_models_on_department_id  (department_id)
#

class RosterModel < ApplicationRecord
  has_many :roster_model_weeks, -> { order "order_no ASC" }, dependent: :destroy
  belongs_to :department

  def self.set_be_used
    RosterModel.all.each do |r|
      be_used = RosterModelState.where(roster_model_id: r.id).count > 0
      r.be_used = be_used
      r.save!
    end
  end
end
