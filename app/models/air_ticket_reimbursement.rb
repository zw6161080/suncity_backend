# == Schema Information
#
# Table name: air_ticket_reimbursements
#
#  id                 :integer          not null, primary key
#  date_of_employment :date
#  route              :string
#  apply_date         :date
#  reimbursement_date :date
#  remarks            :string
#  user_id            :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  ticket_price       :decimal(10, 2)
#  exchange_rate      :decimal(10, 2)
#  ticket_price_macau :decimal(10, 2)
#
# Indexes
#
#  index_air_ticket_reimbursements_on_user_id  (user_id)
#

class AirTicketReimbursement < ApplicationRecord
  validates :user_id,:route,:ticket_price,:exchange_rate,:ticket_price_macau,:apply_date,:reimbursement_date,
            presence: true
  belongs_to :user

  scope :by_air_apply_and_reimbursement, lambda { |apply_date, reimbursement_date|
    where.not('(reimbursement_date IS NOT NULL AND reimbursement_date <= :apply_date) OR apply_date > :reimbursement_date ',
              apply_date: apply_date,
              reimbursement_date: reimbursement_date)
  }

  scope :by_air_date, lambda { |date|
    where('apply_date <= :date AND (reimbursement_date IS NULL OR reimbursement_date >= :date)', date: date)
  }

  def is_first_air_ticket_for_user?
    AirTicketReimbursement.where(user_id: self.user_id).count == 1
  end

end
