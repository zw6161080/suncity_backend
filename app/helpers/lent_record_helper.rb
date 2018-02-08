module LentRecordHelper
  def lent_required_array
    [:user_id, :lent_begin, :deployment_type, :temporary_stadium_id, :calculation_of_borrowing]
  end

  def lent_permitted_array
    [:lent_end, :return_compensation_calculation, :comment]
  end
end