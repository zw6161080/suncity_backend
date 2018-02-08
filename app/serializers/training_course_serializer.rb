class TrainingCourseSerializer < ActiveModel::Serializer
  attributes *TrainingCourse.column_names
  belongs_to :user, serializer: UserWithPAndLAndDSerializer
end
