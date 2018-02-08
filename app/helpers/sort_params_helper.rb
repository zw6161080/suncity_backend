module SortParamsHelper
  def sort_column_sym(sort_column_name, default_column_name)
    (sort_column_name.presence || default_column_name).to_sym
  end

  def sort_direction_sym(asc_or_desc, default_direction)
    if asc_or_desc.present? and %w(asc desc).include? asc_or_desc.downcase
      asc_or_desc.downcase.to_sym
    else
      default_direction
    end
  end

  def final_sort_column(sort_column_name, list_name)
    if Config.get(:list_column_collection)[list_name].include?(sort_column_name)
      sort_column_name
    else
      nil
    end
  end
end