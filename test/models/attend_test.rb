require "test_helper"

class AttendTest < ActiveSupport::TestCase
  def attend
    @attend ||= Attend.new
  end

  def test_valid
    assert attend.valid?
  end

  def test_update_from_SQLServer
    ENV['DB_ENV_SUNCITY_MSSQL_HOST'] = "ylemon.tech"

    byebug
    Attend.update_working_time(Time.zone.local(2017, 3, 1).to_date)
    byebug
  end
end
