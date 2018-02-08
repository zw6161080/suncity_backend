module ProfileHelper
  def select_columns
    if params[:select_columns]
      params[:select_columns]
    else
      ApplicantSelectColumnTemplate.default_columns(region: params[:region])
    end
  end

  def profile_to_json_with_select_columns(profiles, column_keys, class_name)
    {
        fields: class_name.find_fields(column_keys).as_json,
        records: profiles.map{|profile|
          {id: profile.id}.merge(profile.as_json_only_fields(column_keys))
        }
    }
  end
end