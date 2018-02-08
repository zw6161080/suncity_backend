class PerformanceInterviewSerializer < ActiveModel::Serializer
  attributes *PerformanceInterview.column_names,
             :interview_time

  belongs_to :appraisal
  belongs_to :appraisal_participator
  has_many :attachment_items
  belongs_to :operator
  belongs_to :performance_moderator

  def interview_time
    if object.interview_time_begin && object.interview_time_end
      "#{object.interview_time_begin.strftime('%H:%M')}~#{object.interview_time_end.strftime('%H:%M')}"
    end
  end

end
