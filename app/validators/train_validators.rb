module TrainValidators
  class TrainWithRightValueValidator<ActiveModel:: Validator
    def validate(record)
      # if record.locations.empty?
      #   record.errors[:base] << "This train doesn't select  location "
      # end
      #
      # if record.positions.empty?
      #   record.errors[:base] << "This train doesn't select  position "
      # end
      #
      # if record.departments.empty?
      #   record.errors[:base] << "This train doesn't select  department "
      # end

      # if record.users.empty?
      #   record.errors[:base] << "This train doesn't have  user by invited "
      # end

      tag = true
      record.grade.each{|item|
        res = Config.get('selects')['grade']['options'].collect{|hash|hash['key']}.include? item
        tag = false unless res
      } if record.grade
      record.errors[:base] << "This train doesn't have select grade" unless tag

      tag = true
      record.division_of_job.each{|item|
        res = Config.get('selects')['division_of_job']['options'].collect{|hash|hash['key']}.include? item
        tag = false unless res
      } if record.division_of_job
      record.errors[:base] << "This train doesn't have select division_of_job" unless tag

      # tag = true
      # tag = false if record.titles.count < 1
      # tag = false if record.classes.count < 1
      #
      # record.errors[:base] << "This train doesn't have right setting of classes" unless tag





    end
  end
end