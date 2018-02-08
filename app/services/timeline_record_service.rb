class TimelineRecordService
  class << self
    def previous_career_record(record)
      targets = record.user.career_records.order_by(:career_begin, :asc)
      index_of_record = targets.index record
      pre_index = index_of_record - 1 if (index_of_record > 0)
      return targets[pre_index] if pre_index
      nil
    end

    def update_salary_record_valid_date(user)
      # 查询示例
      # TODO 取消固定年限的设定 改为nil
      # 适用基本查询
      # CareerRecord.where('career_begin <= :date AND (invalid_date > :date OR invalid_date IS NULL)', date: ymd)
      # 适用员工档案查询
      # CareerRecord.where('(valid_date <= :date OR valid_date IS NULL) AND (invalid_date > :date OR invalid_date IS NULL)', date: ymd)
      targets = user.salary_records.order_by(:salary_begin, :asc)
      targets.each do |record|
        index_of_record = targets.index record
        next_index = index_of_record + 1
        next_record = targets[next_index]
        begin_date = record.salary_begin.beginning_of_day
        record.update_columns(
            valid_date: begin_date,
            invalid_date: ((next_record.salary_begin - 1.day) rescue Time.zone.local(2999, 12, 31, 23, 59, 59).end_of_day)
        )
      end
    end

    def next_career_record(record)
      targets = record.user.career_records.order_by(:career_begin, :asc)
      index_of_record = targets.index record
      next_index = index_of_record + 1
      targets[next_index]
    end

    def update_valid_date(user)
      targets = user.career_records.order_by(:career_begin, :asc)
      targets.each do |record|
        index_of_record = targets.index record
        next_index = index_of_record + 1
        pre_index = index_of_record - 1 if (index_of_record > 0)
        next_record = targets[next_index]
        pre_record = targets[pre_index] if pre_index
        begin_date = record.career_begin.beginning_of_day
        begin_date = Time.zone.local(999, 1, 1, 0, 0, 1).beginning_of_day unless pre_record
        record.update_columns(
            valid_date: begin_date,
            invalid_date: (next_record.career_begin rescue Time.zone.local(2999, 12, 31, 23, 59, 59).end_of_day)
        )
      end
    end

    def update_lent_record
      targets = CareerRecord.all
      mistake_record = []
      LentRecord.all.each do |lent_record|
        target_career = targets.where(user_id: lent_record.user_id).where('valid_date <= ?', lent_record.lent_begin).where('invalid_date >= ?', lent_record.lent_begin)
        target_career =target_career.where('invalid_date >= ?', lent_record.lent_end) if lent_record.lent_end
        mistake_record << lent_record unless (target_career.count == 1 && !target_career.first)
        lent_record.update(career_record_id: target_career.first.id) if target_career.first
      end
      mistake_record
    end

    def update_museum_record
      targets = CareerRecord.all
      mistake_record = []
      MuseumRecord.all.each do |museum_record|
        target_career = targets.where(user_id: museum_record.user_id).where('valid_date <= ?', museum_record.date_of_employment).where('invalid_date >= ?', museum_record.date_of_employment)
        mistake_record << museum_record unless (target_career.count == 1 && !target_career.first)
        museum_record.update(career_record_id: target_career.first.id) if target_career.first
      end
      mistake_record
    end

    def get_relative_career_record(user, date_begin, date_end = nil)
      targets = user.career_records
      target = targets.where('career_begin <= :date AND invalid_date >= :date', date: date_begin)
      target = targets.where('career_begin <= :date AND invalid_date >= :date', date: date_end) if date_end
      target.first rescue nil
    end

    def can_lent_record_update(params)
      record = LentRecord.find(params[:id])
      return false unless record
      user = record.user
      _begin = Time.zone.parse(params[:lent_begin]).beginning_of_day rescue record.lent_begin
      _end = Time.zone.parse(params[:lent_end]).end_of_day rescue nil
      return false unless _begin
      if _begin && _end
        return false unless (_begin < _end)
      end
      # 验证匹配的职称信息
      target = record.career_record
      return false unless target
      # 验证是否于其他调馆暂借冲突
      lent_records = target.lent_records.where.not(id: record.id)
      museum_records = target.museum_records
      # 调馆暂借不存在相互包含的情况
      # 不在任何时间段之内
      result = lent_records.where.not(lent_end: nil).where('lent_begin <= :date AND lent_end >= :date', date: _begin)
      return false unless result.empty?
      # 不包含任何时间点
      if _begin && _end
        result_a = lent_records.where('lent_begin >= :from AND lent_begin <= :to', from: _begin, to: _end)
        result_b = museum_records.where('date_of_employment >= :from AND date_of_employment <= :to', from: _begin, to: _end)
        return false unless (result_a.empty? && result_b.empty?)
      end
      # 验证开始时间是否于调馆暂借重合
      lent_date_points = lent_records.pluck(:lent_begin).map { |r| r.beginning_of_day rescue nil }.compact
      museum_date_points = museum_records.pluck(:date_of_employment).map { |r| r.beginning_of_day rescue nil }.compact
      return false if lent_date_points.concat(museum_date_points).include? _begin
      # 验证目标场馆于原场馆相同
      location_id = target.location_id
      museum = target.museum_records.where('date_of_employment < :date', date: _begin).order('date_of_employment desc').first
      location_id = museum.location_id if museum
      return false if (params[:temporary_stadium_id] && (params[:temporary_stadium_id].to_i == location_id))
      # 判断目标场馆中是否存在对应部门职位
      target_location = Location.find(params[:temporary_stadium_id]) rescue record.temporary_stadium
      return false unless target_location
      department = target.department
      position = target.position
      return false unless target_location.departments.exists? department
      return false unless target_location.positions.exists? position
      true
    end

    def can_lent_record_create(params)
      _begin = Time.zone.parse(params[:lent_begin]).beginning_of_day rescue nil
      _end = Time.zone.parse(params[:lent_end]).end_of_day rescue nil
      return false unless _begin
      if _begin && _end
        return false unless (_begin < _end)
      end
      user = User.find(params[:user_id])
      return false unless user
      # 验证匹配的职称信息
      target = get_relative_career_record(user, _begin, _end)
      return false unless target
      # 验证是否于其他调馆暂借冲突
      lent_records = target.lent_records
      museum_records = target.museum_records
      # 调馆暂借不存在相互包含的情况
      # 不在任何时间段之内
      result = lent_records.where.not(lent_end: nil).where('lent_begin <= :date AND lent_end >= :date', date: _begin)
      return false unless result.empty?
      # 不包含任何时间点
      if _begin && _end
        result_a = lent_records.where('lent_begin >= :from AND lent_begin <= :to', from: _begin, to: _end)
        result_b = museum_records.where('date_of_employment >= :from AND date_of_employment <= :to', from: _begin, to: _end)
        return false unless (result_a.empty? && result_b.empty?)
      end
      # 验证开始时间是否于调馆暂借重合
      lent_date_points = lent_records.pluck(:lent_begin).map { |r| r.beginning_of_day rescue nil }.compact
      museum_date_points = museum_records.pluck(:date_of_employment).map { |r| r.beginning_of_day rescue nil }.compact
      return false if lent_date_points.concat(museum_date_points).include? _begin
      # 验证目标场馆于原场馆相同
      location_id = target.location_id
      museum = target.museum_records.where('date_of_employment < :date', date: _begin).order('date_of_employment desc').first
      location_id = museum.location_id if museum
      return false if (params[:temporary_stadium_id] && (params[:temporary_stadium_id].to_i == location_id))
      # 判断目标场馆中是否存在对应部门职位
      target_location = Location.find(params[:temporary_stadium_id]) rescue nil
      return false unless target_location
      department = target.department
      position = target.position
      return false unless target_location.departments.exists? department
      return false unless target_location.positions.exists? position
      true
    end

    def can_museum_record_update(params)
      transfer_date = Time.zone.parse(params[:date_of_employment]).beginning_of_day rescue nil
      return false unless transfer_date
      record = MuseumRecord.find(params[:id])
      user = record.user
      # 验证匹配的职称信息
      target = record.career_record
      return false unless target
      # 验证是否于其他调馆暂借冲突
      lent_records = target.lent_records
      museum_records = target.museum_records.where.not(id: record.id)
      # 验证开始时间是否于调馆暂借重合
      lent_date_points = lent_records.pluck(:lent_begin).map { |r| r.beginning_of_day rescue nil }.compact
      museum_date_points = museum_records.pluck(:date_of_employment).map { |r| r.beginning_of_day rescue nil }.compact
      return false if lent_date_points.concat(museum_date_points).include? transfer_date
      # 调馆时间点不在有归还日期的暂借之内
      result = lent_records.where.not(lent_end: nil).where('lent_begin <= :date AND lent_end >= :date', date: transfer_date)
      return false unless result.empty?
      # 验证时间是否符合职称信息 -> 超出职称信息有效范围
      return false if ((transfer_date < target.career_begin) || (transfer_date > target.invalid_date))
      target_location = Location.find(params[:location_id]) rescue nil
      # 验证目标场馆于原场馆相同
      return false if (params[:location_id] && (params[:location_id].to_i == target.location_id))
      # 判断目标场馆中是否存在对应部门职位
      return false unless target_location
      department = target.department
      position = target.position
      return false unless target_location.departments.exists? department
      return false unless target_location.positions.exists? position
      true
    end

    def can_museum_record_create(params)
      transfer_date = Time.zone.parse(params[:date_of_employment]).beginning_of_day rescue nil
      return false unless transfer_date
      user = User.find(params[:user_id])
      return false unless user
      # 验证匹配的职称信息
      target = get_relative_career_record(user, transfer_date)
      return false unless target
      # 验证是否于其他调馆暂借冲突
      lent_records = target.lent_records
      museum_records = target.museum_records
      # 验证开始时间是否于调馆暂借重合
      lent_date_points = lent_records.pluck(:lent_begin).map { |r| r.beginning_of_day rescue nil }.compact
      museum_date_points = museum_records.pluck(:date_of_employment).map { |r| r.beginning_of_day rescue nil }.compact
      return false if lent_date_points.concat(museum_date_points).include? transfer_date
      target_location = Location.find(params[:location_id]) rescue nil
      # 调馆时间点不在有归还日期的暂借之内
      result = lent_records.where.not(lent_end: nil).where('lent_begin <= :date AND lent_end >= :date', date: transfer_date)
      return false unless result.empty?
      # 验证目标场馆于原场馆相同
      return false if (params[:location_id] && (params[:location_id].to_i == target.location_id))
      # 判断目标场馆中是否存在对应部门职位
      return false unless target_location
      department = target.department
      position = target.position
      return false unless target_location.departments.exists? department
      return false unless target_location.positions.exists? position
      true
    end

    def can_career_record_update(params)
      record = CareerRecord.find(params[:id]) rescue nil
      # 取得新紀錄的時間
      _begin = Time.zone.parse(params[:career_begin]).beginning_of_day rescue record.career_begin
      _end = Time.zone.parse(params[:career_end]).end_of_day rescue nil
      # 基本判斷（結束時間 晚於 開始時間 不存在开始日期）
      return false unless _begin
      if _begin && _end
        return false unless (_begin < _end)
      end
      return false unless record
      # 判断自身调馆暂借时间范围
      self_lent_records = record.lent_records
      self_museum_records = record.museum_records
      begin_min_limit = [self_lent_records.minimum(:lent_begin), self_museum_records.minimum(:date_of_employment)].compact.min
      end_min_limit = self_lent_records.maximum(:lent_end)
      # 存在调馆暂借记录判断场馆是否改变
      unless self_lent_records.empty? && self_museum_records.empty?
        return false if params[:location_id] && (record.location_id != params[:location_id].to_i)
      end
      # 时间不符合最小范围限制
      return false if begin_min_limit && (_begin > begin_min_limit)
      return false if end_min_limit && (_end < end_min_limit)
      # 查询职称信息集合 职称信息记录 -> 以開始時間為準 降序排列
      order_key = :career_begin
      user = record.user
      targets = user.career_records.where.not(id: params[:id]).order_by(order_key, :asc)
      # 除自身外无其他记录
      if targets.empty?
        match_begin = true
        metch_end = true
        match_begin = _begin < begin_min_limit if begin_min_limit
        metch_end = _end > end_min_limit if (_end && end_min_limit)
        return match_begin && metch_end
      end
      # 存在其他歷史紀錄，判断上一條紀錄和下一條紀錄对时间的限制
      previous_record = targets.where('career_begin <= :begin', begin: _begin).order_by(order_key, :asc).last
      next_record = targets.where('career_begin >= :begin', begin: _begin).order_by(order_key, :asc).first
      begin_limit = (previous_record.career_end || previous_record.career_begin) if previous_record
      end_limit = next_record.career_begin if next_record
      # 不存在上一条职程信息，结束早下一条记录的开始时间
      return (_end || _begin) < end_limit unless previous_record
      # 存在下一条记录 -> 判断结束限制
      if next_record && _end
        return false if _end >= end_limit
      end
      # 通过调馆、暂借判断开始时间
      lent_records = previous_record.lent_records
      museum_records = previous_record.museum_records
      # 不存在暂借和调馆记录
      return _begin > begin_limit if (lent_records.empty? && museum_records.empty?)
      # 存在暂借或调馆记录
      lent_limit = [lent_records.maximum(:lent_begin), lent_records.maximum(:lent_end)].compact.max
      museum_limit = museum_records.maximum(:date_of_employment)
      begin_limit = [lent_limit, museum_limit].compact.max
      return begin_limit < _begin
    end

    def can_career_record_create(params)
      # 取得新紀錄的時間
      _begin = Time.zone.parse(params[:career_begin]).beginning_of_day rescue nil
      _end = Time.zone.parse(params[:career_end]).end_of_day rescue nil
      # 基本判斷（結束時間 晚於 開始時間 不存在开始日期）
      return false unless _begin
      if _begin && _end
        return false unless (_begin < _end)
      end
      # 职称信息记录 -> 以開始時間為準 降序排列
      order_key = :career_begin
      user = User.find(params[:user_id])
      targets = user.career_records.order_by(order_key, :asc)
      # 不存在其他歷史紀錄
      return true if targets.count == 0
      # 存在其他歷史紀錄，判断上一條紀錄和下一條紀錄对时间的限制
      previous_record = targets.where('career_begin <= :begin', begin: _begin).order_by(order_key, :asc).last
      next_record = targets.where('career_begin >= :begin', begin: _begin).order_by(order_key, :asc).first
      begin_limit = (previous_record.career_end || previous_record.career_begin) if previous_record
      end_limit = next_record.career_begin if next_record
      # 不存在上一条职程信息，结束早下一条记录的开始时间
      return (_end || _begin) < end_limit unless previous_record
      # 存在下一条记录 -> 判断结束限制
      if next_record && _end
        return false if _end >= end_limit
      end
      # 通过调馆、暂借判断开始时间
      lent_records = previous_record.lent_records
      museum_records = previous_record.museum_records
      # 不存在暂借和调馆记录
      return _begin > begin_limit if (lent_records.empty? && museum_records.empty?)
      # 存在暂借或调馆记录
      lent_limit = [lent_records.maximum(:lent_begin), lent_records.maximum(:lent_end)].compact.max
      museum_limit = museum_records.maximum(:date_of_employment)
      begin_limit = [lent_limit, museum_limit].compact.max
      return begin_limit < _begin
    end
  end
end
