class RosterEventLog < ApplicationRecord
  establish_connection(:suncity_mssql)
  self.table_name = 'tb_event_log'
  self.primary_key = 'nEventLogIdn'
  default_scope { select_converted_datetime.where('nUserID > 0').where(nReaderIdn: reader_ids) }

  def self.select_converted_datetime
    # 强制把UTC时间9:00转回北京时间9:00
    self.select("*, TodateTimeOffset(dateadd(s, nDateTime, '1970-01-01'),'+08:00') as convertDatetime")
  end

  def readonly?
    true
  end

  def self.of_user(user)
    self.where(nUserID: user.empoid.to_i.to_s)
  end

  def self.of_yesterday
    self.of_date(Date.today-1)
  end

  def self.of_today
    self.of_date(Date.today)
  end

  def self.of_ymd(year, month, day)
    date = "#{year}-#{month}-#{day}".to_date
    self.of_date(date)
  end

  def self.of_date(date)
    # 因为太阳城打卡数据没有考虑时区，打卡时间是以UTC时区计时的，
    # 所以这里故意忽略了时区，强制把北京时间转换成了UTC时间进行筛选查询
    the_yesterday_timestamp = self.force_utc_timestamp(date - 1)
    the_tomorrow_timestamp = self.force_utc_timestamp(date + 1)
    self.where("nDateTime > ?", the_yesterday_timestamp)
        .where("nDateTime < ?", the_tomorrow_timestamp)
  end

  def self.force_utc_timestamp(date)
    date.to_time.to_i + self.timestamp_diff
  end

  def self.timestamp_diff
    Rails.cache.fetch('suncity_bio_star_timestamp_diff') do
      date = Date.today
      utc_time = date.to_time.in_time_zone("UTC")
      y = utc_time.year
      m = utc_time.month
      d = utc_time.day
      h = utc_time.hour
      date.to_time.to_i - "#{y}-#{m}-#{d} #{h}:00:00".to_time.to_i
    end
  end

  def self.reader_ids
    [
      47479,
      47480,
      47482,
      47483,
      47484,
      47485,
      47491,
      47492,
      47493,
      47494,
      47511,
      47512,
      47513,
      47514,
      50218,
      50219,
      55780,
      55783,
      56571,
      56572,
      56573,
      56576,
      61562,
      61563,
      61575,
      63375,
      63380,
      63381,
      63382,
      63383,
      63384,
      63405,
      63406,
      63407,
      63409,
      63410,
      63411,
      63412,
      63445,
      63446,
      63447,
      63448,
      63449,
      63451,
      63452,
      63453,
      63454,
      63465,
      63467,
      63468,
      63565,
      63566,
      63569,
      63570,
      63571,
      63572,
      63573,
      63574,
      94540,
      94541,
      94546,
      94547,
      94551,
      94553,
    ]
  end
end
