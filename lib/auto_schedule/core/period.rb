module AutoSchedule
class Period
  attr_accessor :_id, :_name, :_begin, :_end

  def initialize(id_, name, _begin, _end)
    @_id = id_
    @_name = name
    @_begin = _begin
    @_end = _end
  end

  def inspect
    _begin = datetime.datetime.fromtimestamp(
      @_begin, tz=datetime.timezone.utc).time().strftime('%T')
    _end = datetime.datetime.fromtimestamp(
      @_end, tz=datetime.timezone.utc).time().strftime('%T')
    return "<Period: #{@_id}, name=#{@_name}, time=#{_begin}-#{_end}>"
  end
end
end