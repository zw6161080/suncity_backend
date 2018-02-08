module AutoSchedule
class Node
  attr_accessor :_row, :_left, :_right, :_up, :_down, :_col, :_count, :_symbol, :_row
  
  def initialize
    @_left = self
    @_right = self
    @_up = self
    @_down = self
  end

  def inspect
    "<Node: _count=#{@_count}, object_id=#{object_id}>"
  end

  def appendToRow(row)
    @_row = row
    @_left = row._left
    @_right = row
    row._left._right = self
    row._left = self
  end

  def appendToColumn(col)
    @_col = col
    @_up = col._up
    @_down = col
    col._up._down = self
    col._up = self
    col._count += 1
  end

  def unlinkInRow
    @_left._right = @_right
    @_right._left = @_left
  end

  def unlinkInColumn
    @_up._down = @_down
    @_down._up = @_up
    @_col._count -= 1
  end

  def relinkInRow
    @_left._right = self
    @_right._left = self
  end

  def relinkInColumn
    @_up._down = self
    @_down._up = self
    @_col._count += 1
  end

  def iterInRow
    nodes = []
    node = @_right
    while node != self
      nodes << node
      node = node._right
    end
    nodes
  end

  def iterInColumn
    nodes = []
    node = @_down
    while node != self
      nodes << node
      node = node._down
    end
    nodes
  end

end
end