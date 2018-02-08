class UserWithPAndLAndDSerializer < ActiveModel::Serializer
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
             :department_id

  belongs_to :position
  belongs_to :location
  belongs_to :department

end