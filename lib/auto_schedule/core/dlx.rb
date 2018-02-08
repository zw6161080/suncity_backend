require_relative 'period'
require_relative 'position'
require_relative 'title'
require_relative 'staff'
require_relative 'node'

module AutoSchedule
class DLX
  attr_accessor :_root, :_staffs, :_titles, :_days, :_begin, :_end, :_rows, :_cols

  def initialize(constraints)
    self.preprocess(constraints)
    self.createRoot()
    @_rows = {}
    @_cols = {}
    @_staff_arrangements = {}
    @_staff_vacations = {}
    @_staff_periods = {}
    for staff in @_staffs
      @_staff_arrangements[staff.last._id] = {}
      @_staff_vacations[staff.last._id] = {}
      @_staff_periods[staff.last._id] = {}
    end
    self.createVacationRows()
    self.createArrangementRows()

    @_solution = []
  end


  def preprocess(constraints)
    self.basic(constraints)
    self.period(constraints)
    self.title(constraints)
    self.position(constraints)
    self.staff(constraints)
    self.staff_number(constraints)
    self.prefer_period(constraints)
    self.prefer_vacation(constraints)
    self.partner(constraints)
    self.confliction(constraints)
  end

  def basic(constraints)
    @_begin = constraints['date-range'][0]
    @_end = constraints['date-range'][1]
    @_days = (@_end - @_begin).to_i
    raise "Wrong date range" unless (@_days + 1) % 7 == 0
  end

  def period(constraints)
    @_periods = {}
    constraints['period'].each do |p|
      period = Period.new(p['id'], p['name'], p['begin'], p['end'])
      @_periods[period._id] = period
    end
  end

  def title(constraints)
    @_titles = {}
    constraints['title'].each do |t|
      title = Title.new(t['id'], t['name'])
      @_titles[title._id] = title
    end
  end

  def position(constraints)
    @_positions = {}
    for p in constraints['position']
      position = Position.new(p['id'],
        p['name'],
        p['min-rest-time'] * 60 * 60,
        p['vacation'],
        p['max-rest-gap'],
        p['max-period-type'])

      @_positions[position._id] = position
    end
  end

  def staff(constraints)
    @_staffs = {}
    constraints['staff'].each do |s|
      title = @_titles[s['title-id']]
      position = @_positions[s['position-id']]
      staff = Staff.new(s['id'], s['name'], title, position)
      @_staffs[staff._id] = staff
      title._staffs << staff._id
    end
  end

  def staff_number(constraints)
    @_staff_numbers = {}
    for sn in constraints['staff-number']

      _begin = (sn['date-range'][0] - @_begin).to_i
      _end = (sn['date-range'][1] - @_begin).to_i + 1

      periods = Array(sn['period-id'])
      titles = Array(sn['title-id'])

      for day in _begin.._end
        for period in periods
          for title in titles
            @_staff_numbers[[day, period, title]] = sn['number-range']
          end
        end
      end

    end
  end

  def prefer_period(constraints)
    @_prefer_periods = {}
    return unless constraints['prefer-period']
    for pp in constraints['prefer-period']
      raise "Wrong date range" unless @_begin <= pp['date-range'][0] && pp['date-range'][0] <= pp['date-range'][1] && pp['date-range'][1] <= @_end
      _begin = (pp['date-range'][0] - @_begin).to_i
      _end = (pp['date-range'][1] - @_begin).to_i

      staff = pp['staff-id']
      periods = Array(pp['period-id'])
      for day in _begin.._end
        old_periods = @_prefer_periods[[day, staff]] ? @_prefer_periods[[day, staff]] : []
        periods = (old_periods + periods).flatten.uniq
        @_prefer_periods[[day, staff]] = periods
      end
    end
  end

  def prefer_vacation(constraints)
    @_prefer_vacations = {}
    return unless constraints['prefer-vacation']
    for pv in constraints['prefer-vacation']
      staff = pv['staff-id']
      days = @_prefer_vacations[staff] ? @_prefer_vacations[staff] : []
      for day in pv['days']
        raise "Wrong date range" unless @_begin <= day || day <= @_end
        offset = (day - @_begin).to_i
        days << offset
      end
      @_prefer_vacations[staff] = days.uniq
    end
  end

  def partner(constraints)
    @_partners = {}
    return unless constraints['partner']
    for p in constraints['partner']
      raise "Wrong date range" unless p['date-range'][0] >= @_begin
      raise "Wrong date range" unless p['date-range'][1] <= @_end
      _begin = (p['date-range'][0] - @_begin).to_i
      _end = (p['date-range'][1] - @_begin).to_i + 1

      staffs = p['staff-id']
      raise "Wrong staff group member count" unless staffs.length == 2
      for day in _begin.._end
        unless @_partners.include?(day)
          @_partners[day] = []
        end
        @_partners[day] += Array(staffs)
      end
    end
  end

  def confliction(constraints)
    @_conflictions = {}
    return unless constraints['confliction']
    for c in constraints['confliction']
      raise "Wrong date range" unless c['date-range'][0] >= @_begin
      raise "Wrong date range" unless c['date-range'][1] <= @_end
      _begin = (c['date-range'][0] - @_begin).to_i
      _end = (c['date-range'][1] - @_begin).to_i + 1

      staffs = c['staff-id']
      raise "Wrong confliction staff group count" unless staffs.length == 2
      for day in _begin.._end
        unless @_conflictions[day]
          @_conflictions[day] = []
        end
        @_conflictions[day] += Array(staffs)
      end
    end
  end


  def createRoot
    @_root = Node.new
    @_root._row = @_root
    @_root._col = @_root
    @_root._count = 0
    return @_root
  end

  def createRow(symbol)
    row = Node.new
    row._row = row
    row.appendToColumn(@_root)
    row._symbol = symbol
    return row
  end

  def createColumn
    col = Node.new
    col._col = col
    col._count = 0
    col.appendToRow(@_root)
    return col
  end

  def addNode(row, col)
    node = Node.new
    node.appendToRow(row)
    node.appendToColumn(col)
    return node
  end

  def getRow(symbol)
    @_rows[symbol] = self.createRow(symbol)
    return @_rows[symbol]
  end

  def getColumn(key)
    unless @_cols[key]
      @_cols[key] = self.createColumn()
    end
    return @_cols[key]
  end

  def createVacationRows
    @_vacation_rows = {}
    for week in 0..(@_days / 7)
      for staff in @_staffs
        vacation = staff.last._position._vacation
        next if vacation <= 0
        prefers = @_prefer_vacations.fetch(staff.first, []).select{|day| week * 7 <= day && day < (week + 1) * 7 }
        for weekdays in (0..6).to_a.combination(vacation).to_a
          days = weekdays.map{|day| week * 7 + day}
          next unless (prefers - days).empty?
          symbol = ['vacation', week, staff.last._id, Array(days.sort)]
          row = self.getRow(symbol)
          for day in days
            col = self.getColumn(['arrangement', day, staff.last._id])
            self.addNode(row, col)
            if @_prefer_periods[[day, staff.last._id]]
              col = self.getColumn(['prefer', day, staff.last._id])
              self.addNode(row, col)
            end
          end
          col = self.getColumn(['vacation', week, staff.last._id])
          self.addNode(row, col)
        end
      end
    end
  end

  def createArrangementRows
    @_arrangement_rows = {}
    for day in 0..(@_days)
      for period in @_periods
        for title in @_titles

          key = [day, period.last._id, title.last._id]
          next unless @_staff_numbers[key]
          number_range = @_staff_numbers[key]
          available_staffs = @_titles[title.last._id]._staffs

          for number in ((number_range[0])..(number_range[1]))
            for staffs in available_staffs.to_a.combination(number).to_a
              symbol = ['arrangement', day, period.last._id, title.last._id, staffs.sort]
              row = self.getRow(symbol)
              for staff in staffs
                col = self.getColumn(['arrangement', day, staff])
                self.addNode(row, col)
                if (@_prefer_periods[[day, staff]] && @_prefer_periods[[day, staff]].include?(period.last._id))
                  col = self.getColumn(['prefer', day, staff])
                  self.addNode(row, col)
                end
              end
              col = self.getColumn(['period', day, period.last._id, title.last._id])
              self.addNode(row, col)
            end
          end

        end
      end
    end
  end


  def validate(symbol)
    if symbol[0] == 'arrangement'
      _, day, period, _, staffs = symbol
      for staff in staffs
        if @_staff_arrangements[staff][day - 1]
          prev_period = @_staff_arrangements[staff][day - 1]
          rest_time = 86400 + @_periods[period]._begin.to_i - @_periods[prev_period]._end.to_i
          return false if rest_time < @_staffs[staff]._position._min_rest_time
        end
        if @_staff_arrangements[staff][day + 1]
          next_period = @_staff_arrangements[staff][day + 1]
          rest_time = 86400 + @_periods[next_period]._begin - @_periods[period]._end
          return false if rest_time < @_staffs[staff]._position._min_rest_time
        end
        types = @_staff_periods[staff].keys
        types << period
        types = types.flatten.compact.uniq
        return false if types.length > @_staffs[staff]._position._max_period_type
        if @_conflictions[day]
          x, y = y, x if y == staff
          if (x == staff &&
            @_staff_arrangements[y] &&
            @_staff_arrangements[y][day] &&
            @_staff_arrangements[y][day] == period)
            return false
          end
        end
      end

      if @_partners[day]
        for partner in [@_partners[day]]
          return false if (staffs.include?(partner[0])) ^ (staffs.include?(partner[1]))
        end
      end

    end

    if symbol[0] == 'vacation'
      _, week, staff, days = symbol
      if @_staff_vacations[staff][week - 1]
        prev_days = @_staff_vacations[staff][week - 1]
        return false if (days[0] - prev_days[-1]) > @_staffs[staff]._position._max_rest_gap
      end

      if @_staff_vacations[staff][week + 1]
        next_days = @_staff_vacations[staff][week + 1]
        return false if (next_days[0] - days[-1]) > @_staffs[staff]._position._max_rest_gap
      end
    end

    return true
  end

    def apply_(row)
      symbol = row._row._symbol
      @_solution.append(row._row._symbol)
      if symbol[0] == 'arrangement'
        _, day, period, _, staffs = symbol
        for staff in staffs
          @_staff_arrangements[staff][day] = period
          unless @_staff_periods[staff][period]
            @_staff_periods[staff][period] = 0
          end
          @_staff_periods[staff][period] += 1
        end

      end
      if symbol[0] == 'vacation'
        _, week, staff, days = symbol
        @_staff_vacations[staff][week] = days
      end
    end

    def restore(symbol)
      @_solution.pop()
      if symbol[0] == 'arrangement'
        _, day, period, _, staffs = symbol
        for staff in staffs
          @_staff_arrangements[staff].delete(day)
          @_staff_periods[staff][period] -= 1
          if @_staff_periods[staff][period] == 0
            @_staff_periods[staff].delete(period)
          end
        end
      end
      if symbol[0] == 'vacation'
        _, week, staff, days = symbol
        @_staff_vacations[staff][week] = nil
      end
    end

    def unlink(col)
      col.unlinkInRow()
      for row in col.iterInColumn
        for node in row.iterInRow
          node.unlinkInColumn
        end
      end
    end

    def relink(col)
      for row in col.iterInColumn.reverse
        for node in row.iterInRow.reverse
          node.relinkInColumn
        end
      end
      col.relinkInRow
    end

    def solve()
      return true if @_root._right == @_root
      selected = @_root.iterInRow.min_by{|col| col._count}
      unlink(selected)
      for row in selected.iterInColumn
        next unless validate(row._row._symbol)
        apply_(row)
        for node in row.iterInRow
          next if node._row == node
          unlink(node._col)
        end
        return true if self.solve()
        for node in row.iterInRow.reverse
          next if node._row == node
          relink(node._col)
        end
        restore(row._row._symbol)
      end
      relink(selected)
      return false
    end

  def outputSolution()
    result = {}
    date_hash = Hash[(0..((@_begin..@_end).count-1)).zip (@_begin..@_end).to_a]
    for sid, staff in @_staffs
      for symbol in @_solution
        if symbol[0] == 'arrangement'
          _, day, pid, _, staffs = symbol
          period = @_periods[pid]._id
          for staff in staffs
            result[[date_hash[day], staff]] = period
          end
        elsif symbol[0] == 'vacation'
          _, _, staff, days = symbol
          for day in days
            result[[date_hash[day], staff]] = '公休'
          end
        end
      end
    end

    result
  end

end
end