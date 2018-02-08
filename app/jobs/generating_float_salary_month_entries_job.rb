class GeneratingFloatSalaryMonthEntriesJob < ApplicationJob
  attr_accessor :item_id
  queue_as :default
  rescue_from(StandardError) do |exception|
    # Do something with the exception
    FloatSalaryMonthEntry.where(id: item_id).destroy_all if item_id
    Rails.logger.info "backtrace: #{exception} "
    Rails.logger.info "backtrace: #{exception.backtrace} "
    raise exception
  end

  def perform(float_salary_month_entry)
    self.item_id =float_salary_month_entry.id
    if  float_salary_month_entry.status == 'generating'
      float_salary_month_entry.update(employees_count: ProfileService.float_salary_month_entries_users(float_salary_month_entry.year_month).count)
      LocationDepartmentStatus.create_with_params(float_salary_month_entry.year_month, float_salary_month_entry.id)
      LocationStatus.create_with_params(float_salary_month_entry.year_month, float_salary_month_entry.id)
      # float_salary_month_entry.create_bonus_element_month_values
      # 创建员工份数
      float_salary_month_entry.create_bonus_element_items
      float_salary_month_entry.create_bonus_element_month_shares_and_amounts
      # 创建部门份数
      # 创建部门基数
      float_salary_month_entry.update(status: :not_approved)
    end
  end
end
