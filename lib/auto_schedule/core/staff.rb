module AutoSchedule
class Staff
  attr_accessor :_id, :_name, :_titles, :_position

  def initialize(id_, name, title, position)
    @_id = id_
    @_name = name
    @_titles = title
    @_position = position
  end

  def inspect
    return "<Staff: #{@_id}, name=#{@_name}, title=#{@_titles}, position=#{@_position}>"
  end
end
end