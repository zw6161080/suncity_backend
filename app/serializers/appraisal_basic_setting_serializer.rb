class AppraisalBasicSettingSerializer < ActiveModel::Serializer
  attributes *AppraisalBasicSetting.column_names

  has_many :appraisal_attachments

end
