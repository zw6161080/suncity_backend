module FormedProfileUpdatedParamsHelper
  def formed_edit_params(edit_params, action, profile)
    if edit_params.is_a?(Hash)
        #新增暂借信息时的特化逻辑
      if edit_params[:section_key] == 'lent_information' && action == 'add_row'
        edit_params[:new_row]['original_hall'] = profile.data['position_information']['field_values']['location'] if  edit_params[:new_row].is_a?(Hash)
        #新增薪酬历史时的特化逻辑
      elsif  edit_params[:section_key] == 'salary_history' && action == 'add_row'
        if edit_params[:new_row][:salary_template_id].to_i == 0
          edit_params[:new_row][:hide_column].keys.each do |key|
            edit_params[:new_row][key] = edit_params[:new_row][:hide_column][key]
          end
          edit_params[:new_row]['total_salary'] = (BigDecimal(edit_params[:new_row]['basic_salary'].to_s) + BigDecimal(edit_params[:new_row]['bonus'].to_s) + BigDecimal(edit_params[:new_row]['attendance_award'].to_s) + BigDecimal(edit_params[:new_row]['house_bonus'].to_s)).to_s
        else
          template = SalaryTemplate.find(edit_params[:new_row][:salary_template_id]) rescue nil
          if template
            # edit_params[:new_row]['salary_unit'] = template.salary_unit
            (Config.get(:constants_collection)['SalaryHistoryHideColumn'] - ['salary_unit', 'basic_salary_unit', 'bonus_unit', 'attendance_award_unit', 'house_bonus_unit']).each do |item|
              edit_params[:new_row][item] = (BigDecimal(template[item].to_s) + BigDecimal(edit_params[:new_row][:hide_column][item].to_s)).to_s
            end
            edit_params[:new_row]['total_salary'] = (BigDecimal(edit_params[:new_row]['basic_salary'].to_s) + BigDecimal(edit_params[:new_row]['bonus'].to_s) + BigDecimal(edit_params[:new_row]['attendance_award'].to_s) + BigDecimal(edit_params[:new_row]['house_bonus'].to_s)).to_s
          end
        end

        # 编辑薪酬历史时的特化逻辑
      elsif  edit_params[:section_key] == 'salary_history' && action == 'edit_row_fields'
        if edit_params[:fields][:salary_template_id].to_i == 0
          edit_params[:fields][:hide_column].keys.each do |item|
            edit_params[:fields][item] = edit_params[:fields][:hide_column][item]
          end
          edit_params[:fields]['total_salary'] = (BigDecimal(edit_params[:fields]['basic_salary'].to_s) + BigDecimal(edit_params[:fields]['bonus'].to_s) + BigDecimal(edit_params[:fields]['attendance_award'].to_s) + BigDecimal(edit_params[:fields]['house_bonus'].to_s)).to_s
        else
          template = SalaryTemplate.find(edit_params[:fields][:salary_template_id]) rescue nil
          if template
            # edit_params[:fields]['salary_unit'] = template.salary_unit
            (Config.get(:constants_collection)['SalaryHistoryHideColumn'] - ['salary_unit', 'basic_salary_unit', 'bonus_unit', 'attendance_award_unit', 'house_bonus_unit']).each do |item|
              edit_params[:fields][item] = (BigDecimal(template[item].to_s) + BigDecimal(edit_params[:fields][:hide_column][item].to_s)).to_s
            end
            edit_params[:fields]['total_salary'] = (BigDecimal(edit_params[:fields]['basic_salary'].to_s) + BigDecimal(edit_params[:fields]['bonus'].to_s) + BigDecimal(edit_params[:fields]['attendance_award'].to_s) + BigDecimal(edit_params[:fields]['house_bonus'].to_s)).to_s
          end
        end
      end
      edit_params
    end
  end
end