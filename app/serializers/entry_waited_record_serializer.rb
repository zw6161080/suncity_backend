class EntryWaitedRecordSerializer < ActiveModel::Serializer
  attributes *ApplicantProfile.column_names,
             :applicant_position,
             :name

  def name
    {
        chinese_name: object.chinese_name,
        english_name: object.english_name,
        simple_chinese_name: object.chinese_name
    }
  end

  def applicant_position
    object.applicant_positions.where(status: 'entry_needed').first.as_json(include: [:department, :position])
  end
end
