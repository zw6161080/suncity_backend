class WrwtSerializer < ActiveModel::Serializer
  attributes *Wrwt.column_names

  def airfare_type
    if object.provide_airfare
      object.airfare_type
    else
      nil
    end
  end

  def airfare_count
    if self.airfare_type == 'count'
      object.airfare_count
    else
      nil
    end
  end
end
