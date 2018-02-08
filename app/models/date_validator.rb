class DateValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})\/(((0[13578]|1[02])\/(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)\/(0[1-9]|[12][0-9]|30))|(02\/(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))\/02\/29)/
      record.errors[attribute] << (options[:message] || "is not a date")
    end
  end
end
class EndDateCannotBeGreaterThanTodayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    year,month,day = value.split('/')
    if day == '29' && month == '02'
      end_date = (Time.zone.local(year,month,day) + 1.year + 1.day).midnight
    else
      end_date = (Time.zone.local(year,month,day) + 1.year).midnight
    end
    if Time.zone.now.midnight < end_date
      record.errors[attribute] << (options[:message] || "can't be greater than today")
    end

  end
end