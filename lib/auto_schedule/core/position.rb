module AutoSchedule
class Position
  attr_accessor :_id, :_name, :_min_rest_time, :_vacation, :_max_rest_gap, :_max_period_type

  def initialize(id_, name, min_rest_time, vacation, max_rest_gap, max_period_type)
    @_id = id_
    @_name = name
    @_min_rest_time = min_rest_time
    @_vacation = vacation
    @_max_rest_gap = max_rest_gap
    @_max_period_type = max_period_type
    # assert 0 <= @_vacation <= 7
  end

  def inspect
    return "<Position: ##{@_id}, name=#{@_name}, min_rest_time=#{@_min_rest_time}, vacation=#{@_vacation}, max_rest_gap=#{@_max_rest_gap}, max_period_type=#{@_max_period_type}>"
  end
end
end