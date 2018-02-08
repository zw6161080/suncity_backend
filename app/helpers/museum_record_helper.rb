module MuseumRecordHelper
  def museum_required_array
    [:user_id, :date_of_employment, :deployment_type,  :salary_calculation, :location_id]
  end

  def museum_permitted_array
    [ :comment]
  end
end