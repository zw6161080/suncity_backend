class EntryListByTrainSerializer < ActiveModel::Serializer
  attributes *EntryList.create_params
  belongs_to :user,  serializer: UserWithPAndLAndDSerializer
  belongs_to :creator, class_name: 'User', foreign_key: 'creator_id', serializer: UserWithPAndLAndDSerializer
  belongs_to :title, serializer: RawTitleSerializer


  def working_status
    object.working_status
  end

  def is_can_be_absent
    object.is_can_be_absent
  end

  def is_in_working_time
    object.is_in_working_time
  end
end
