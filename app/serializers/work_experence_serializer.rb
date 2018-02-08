class WorkExperenceSerializer < ActiveModel::Serializer
  attributes *WorkExperence.column_names, :user

  def user
    ActiveModelSerializers::SerializableResource.new(object.profile.user).as_json[:user] if object.profile
  end

end
