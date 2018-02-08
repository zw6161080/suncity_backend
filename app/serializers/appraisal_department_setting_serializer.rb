class AppraisalDepartmentSettingSerializer < ActiveModel::Serializer
  attributes *AppraisalDepartmentSetting.column_names, :group_situation

  belongs_to :location
  belongs_to :department
  has_many :appraisal_groups

  def group_situation
    {
      group_A: object.appraisal_basic_setting.group_A,
      group_B: object.appraisal_basic_setting.group_B,
      group_C: object.appraisal_basic_setting.group_C,
      group_D: object.appraisal_basic_setting.group_D,
      group_E: object.appraisal_basic_setting.group_E
    }
  end

end
