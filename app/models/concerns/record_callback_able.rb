module RecordCallbackAble

  extend ActiveSupport::Concern

  included do


    def begin_date
      case self.class.name
      when 'SalaryRecord'
        self.salary_begin
      when 'WelfareRecord'
        self.welfare_begin
      when 'LentRecord'
        self.lent_begin
      when 'MuseumRecord'
        self.date_of_employment
      when 'CareerRecord'
        self.career_begin
      end
    end






    def valid_status
      if is_being_valid?
        throw :abort
      end
    end


  end
end
