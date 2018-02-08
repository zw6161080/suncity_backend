class ClassSettingsController < ApplicationController
  before_action :set_class_setting, only: [:update, :destroy]
  before_action :set_be_used, only: [:index]

  def index
    # authorize ClassSetting
    result = ClassSetting.all.pluck(:department_id).compact.uniq.sort.map do |dept_id|
      department = Department.find(dept_id)
      if department
        # class_group_map_of_department = class_group_map[dept_id].sort { |c| c.code }.reverse
        # class_group_map_of_department.map { |cs| cs.as_json(methods: [:fmt_code]) }.as_json

        class_table = class_group_map[dept_id].map { |cs| cs.as_json(methods: [:fmt_code]) }.as_json.sort { |c| c["code"].to_i }.reverse
        {
          department_id: dept_id,
          department_chinese_name: department.try(:chinese_name),
          department_english_name: department.try(:english_name),
          department_simple_chinese_name: department.try(:simple_chinese_name),
          class_count: class_count_map[dept_id],
          class_table: class_table,
        }
      end
    end
    response_json result.as_json
  end

  def create
    authorize ClassSetting
    ActiveRecord::Base.transaction do
      # new_max_code = find_code
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:department_id] && params[:name] && params[:display_name] && params[:code] && params[:start_time] && params[:is_next_of_start] && params[:end_time] && params[:is_next_of_end] && params[:late_be_allowed] && params[:leave_be_allowed] && params[:overtime_before_work] && params[:overtime_after_work]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:start_time] > params[:end_time]
      new_codes = find_codes(params[:departments].count)
      params[:departments].each.with_index do |dept_id, idx|
        class_setting = ClassSetting.create(class_setting_params)
        class_setting.start_time = params[:start_time].in_time_zone
        class_setting.end_time = params[:end_time].in_time_zone
        class_setting.department_id = dept_id
        # new_apply_code = new_max_code + idx
        new_apply_code = new_codes[idx]
        class_setting.code = new_apply_code.to_s.rjust(3, '0')
        class_setting.save

        RosterPreference.add_new_class_people_preference(dept_id, class_setting)
      end

      response_json :ok
    end
  end

  def update
    authorize ClassSetting
    result = @class_setting.update_attributes(class_setting_params)
    response_json result
  end

  def destroy
    authorize ClassSetting
    unless @class_setting.be_used
      dept_id = @class_setting.department_id
      RosterPreference.remove_class_people_preference(dept_id, @class_setting)
      @class_setting.destroy
    end
    response_json :ok
  end

  def options
    all_options = {}
    departments = Department.where(region_key: 'macau')
    all_code = ClassSetting.all.pluck(:code).compact.uniq.select { |x| x != "000" }.sort
    all_options[:all_code] = all_code
    all_options[:departments] = departments
    response_json all_options
  end

  def transform_code_to_new_code
    ClassSetting.all.each do |cs|
      cs.new_code = cs.code.to_s.rjust(3, "0")
      cs.save
    end

    response_json :ok
  end

  def transform_new_code_to_code
    ClassSetting.all.each do |cs|
      cs.code = cs.new_code
      cs.save
    end

    response_json :ok
  end

  private

  def class_setting_params
    params.require(:class_setting).permit(
      :region,
      :department_id,
      :name,
      :display_name,
      :code,
      :start_time,
      :is_next_of_start,
      :end_time,
      :is_next_of_end,
      :late_be_allowed,
      :leave_be_allowed,
      :overtime_before_work,
      :overtime_after_work
    )
  end

  def set_class_setting
    @class_setting = ClassSetting.find(params[:id])
  end

  def class_group_map
    ClassSetting.all.group_by { |klass| klass.department_id }
  end

  def class_count_map
    ClassSetting.all.group('department_id').count
  end

  # def find_code
  #   arr = ClassSetting.all.pluck(:code).map { |i| Integer(i) rescue nil}.compact.uniq.select { |x| x != 0 }.sort
  #   arr.empty? ? 1 : arr.last + 1
  # end

  def find_codes(count)
    arr = ClassSetting.all.pluck(:code).map { |i| Integer(i, 10) rescue nil}.compact.uniq.select { |x| x != 0 }.sort
    max_item = arr.empty? ? 0 : arr.last
    tmp_arr_size = max_item + count + 1
    tmp_arr = Array.new(tmp_arr_size).map.with_index do |item, idx|
      (arr.include? idx) ? idx : nil
    end

    result = tmp_arr.each_with_index.inject([]) do |acc, (item, idx)|
      acc << idx if (item == nil && idx != 0)
      acc
    end.take(count)

    result
  end

  # def find_code
  #   arr = ClassSetting.all.pluck(:code).compact.uniq.select { |x| x.to_s != 0 && x != "000" }.sort
  #   idx = arr.find_index { |item| arr.find_index(item) != (item.to_i - 1) }
  #   if idx == 0 || (idx.nil? && arr.empty?)
  #     return 1
  #   elsif idx.nil? && !arr.empty?
  #     return (arr.count + 1)
  #   else
  #     arr[idx - 1].to_i + 1
  #   end
  # end

  def set_be_used
    ClassSetting.set_be_used
  end
end
