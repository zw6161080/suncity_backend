class HolidayAccumulationRecordSerializer < ActiveModel::Serializer
  attributes *User.column_names, :count

  has_one :profile
  belongs_to :position
  belongs_to :department

  def count
    HolidayCalculateService.calculate_accumulation_days(@instance_options[:query_params][:query_date], object, @instance_options[:query_params][:holiday_type], @instance_options[:query_params][:apply_type])
  end
end
