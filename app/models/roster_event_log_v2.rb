# coding: utf-8
class RosterEventLogV2 < ApplicationRecord
  establish_connection(:suncity_mssql)

  def self.of_ym(yyyy, mm)
    self.find_by_sql(
      "select convert(varchar(20),a.USRID) as nUserID, convert(varchar(20), a.SRVDT, 20) as convertDatetime
      from T_LG#{yyyy}#{mm} a inner join T_DEV b on a.DEVUID = b.DEVID
      where b.DEVTYPUID in (8, 9)
      and a.EVT in (4865, 4866, 4098)"
    )
  end

  def self.of_bare_ymd(year, month, day)
    yyyy = year.to_s.rjust(4, '0')
    mm = month.to_s.rjust(2, '0')
    this_day = Time.zone.local(year, month, day)
    next_day = this_day + 1.day
    self.of_ym(yyyy, mm)
      .select { |log| log.convertDatetime < next_day }
      .select { |log| log.convertDatetime >= this_day }
  end

  def self.of_ymd(year, month, day)
    self.of_date(Time.zone.local(year, month, day))
  end

  def self.of_date(date)
    # 取日期前一天至次日内，共三天的打卡数据（为了处理次日排班的问题）
    yesterday = date - 1.day
    tomorrow = date + 1.day
    self.of_bare_ymd(yesterday.year, yesterday.month, yesterday.day) +
      self.of_bare_ymd(date.year, date.month, date.day) +
      self.of_bare_ymd(tomorrow.year, tomorrow.month, tomorrow.day)
  end

  def self.of_user_date(user, date)
    self.of_date(date).select { |log| log.nUserID == user.empoid.to_i.to_s }
  end

end
