class UserForAllTrainsSerializer < ActiveModel::Serializer
  attributes :id,
             :empoid,
             :chinese_name,
             :english_name,
             :simple_chinese_name,
             :id_card_number,
             :email,
             :company_name,
             :employment_status,
             :grade,
             :position_id,
             :location_id,
             :department_id,
             :trains
  has_one :profile
  belongs_to :position
  belongs_to :location
  belongs_to :department

  def trains
    object.completed_trains
  end

end