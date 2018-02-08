module DateRangeExtension
  def day_range
    self.beginning_of_day..self.end_of_day
  end

  def month_range
    self.beginning_of_month..self.end_of_month
  end

  def year_range
    self.beginning_of_year..self.end_of_year
  end
end

class Date
  include DateRangeExtension
end

class Time
  include DateRangeExtension
end

class ActiveSupport::TimeWithZone
  include DateRangeExtension
end
