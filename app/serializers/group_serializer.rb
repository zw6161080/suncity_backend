class GroupSerializer < ActiveModel::Serializer
  attributes *Group.column_names, :department_ids, :key

  has_many :departments

  def department_ids
    object.departments.collect(&:id)
  end

  def key
    object.id.to_s
  end

  def can_be_destroy
    !CareerRecord.pluck(:group_id).include?(object.id)
  end

  def can_destroy
    can_be_destroy
  end
end
