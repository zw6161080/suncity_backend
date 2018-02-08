class ReviseClockItemSerializer < ActiveModel::Serializer
  attributes :id, :clock_date, :created_at ,:money
  belongs_to :user
  belongs_to :revise_clock
  def money
    BigDecimal(100)
  end
end
