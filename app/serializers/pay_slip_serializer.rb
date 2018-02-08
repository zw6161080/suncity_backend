class PaySlipSerializer < ActiveModel::Serializer
  attributes *PaySlip.column_names, :salary_values, :user
  def user
    user = ActiveModelSerializers::SerializableResource.new(object.user, serializer: UserForPaySlipSerializer).serializer_instance.as_json
    empoid = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 1).first).serializer_instance.value rescue nil
    chinese_name = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 2).first).serializer_instance.value['chinese_name'] rescue nil
    english_name = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 2).first).serializer_instance.value['english_name'] rescue nil
    simple_chinese_name = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 2).first).serializer_instance.value['simple_chinese_name'] rescue nil
    company_name = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 5).first).serializer_instance.value rescue nil
    location = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 6).first).serializer_instance.value rescue nil
    department = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 7).first).serializer_instance.value rescue nil
    position = ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month, salary_column_id: 1001).first, serializer: SalaryValueWithNewSalaryColumnIdSerializer).serializer_instance.value rescue nil
    user.merge({empoid: empoid,
                chinese_name: chinese_name,
                english_name: english_name,
                simple_chinese_name: simple_chinese_name,
                company_name: company_name,
                location: location,
                department: department, position: position})

  end

  def salary_values
    ActiveModelSerializers::SerializableResource.new(SalaryValue.where(user_id: object.user_id, year_month: object.year_month).where.not('salary_column_id < 1000'), each_serializer: SalaryValueWithNewSalaryColumnIdSerializer).as_json[:salary_values]
  end

  def entry_on_this_month
    ProfileService.is_join_in_this_month(object.user, object.year_month)
  end

  def leave_on_this_month
    ProfileService.is_leave_in_this_month(object.user, object.year_month)
  end
end
