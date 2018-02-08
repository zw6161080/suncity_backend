module AutoSchedule
class Title
  attr_accessor :_id, :_name, :_staffs

  def initialize(id_, name)
    @_id = id_
    @_name = name
    @_staffs = []
  end

  def inspect
    return "<Title: #{@_id}, name=#{@_name}, staff=#{@_staffs}>"
  end
end
end