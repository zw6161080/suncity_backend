class UserForPaySlipSerializer < ActiveModel::Serializer
  attributes :id,
             :id_card_number,
             :email,
             :employment_status,
             :grade,
             :position_id,
             :location_id,
             :department_id,
             :career_entry_date,
             :tax_number,
             :sss_number,
             :position

  def tax_number
    object.profile.data['personal_information']['field_values']['tax_number']
  end

  def sss_number
    object.profile.data['personal_information']['field_values']['sss_number']
  end


end