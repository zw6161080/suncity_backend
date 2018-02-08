class OptionSerializer < ActiveModel::Serializer
  attributes  *Option.create_params

  has_many :attend_attachments
end