# == Schema Information
#
# Table name: profit_conflict_informations
#
#  id         :integer          not null, primary key
#  have_or_no :boolean
#  number     :string
#  user_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_profit_conflict_informations_on_user_id  (user_id)
#

class ProfitConflictInformation < ApplicationRecord
  belongs_to :user
  validates :have_or_no, inclusion: {in: [false, true]}

  def destory_number_when_no
    if params[:have_or_no] == false
      params[:number] = nil
    end
  end
end
