class ProfessionalQualificationSerializer < ActiveModel::Serializer
  attributes *ProfessionalQualification.column_names, :profile

  def profile
    ActiveModelSerializers::SerializableResource.new(object.profile.user, serializer: UserSerializer) rescue nil
  end
end
