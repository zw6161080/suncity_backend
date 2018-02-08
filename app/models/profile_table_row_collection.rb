class ProfileTableRowCollection
  include ProfileEnumerable

  def initialize(rows=[])
    if rows.nil?
      @rows = []
    else
      @rows = rows.map do |row|
        ProfileTableRow.new(row)
      end
    end
  end

  def enumerable_item
    @rows
  end

  def as_json(*args)
    @rows.as_json
  end

  def append_row(row)
    self.push row
  end

  def find_row_by_id(id)
    @rows.find do |row|
      row.id == id
    end
  end

  def add_row(params)
    new_row = ProfileTableRow.new(params['new_row'].as_json)
    append_row(new_row)
    new_row
  end

  def edit_row_fields(params)
    row_id = params['row_id']
    row = find_row_by_id(row_id)
    if row
      params[:fields].each do |field, value|
        row.update(field, value)
      end
    end
  end

  def remove_row(params)
    self.select! do |row|
      row.id != params['row_id']
    end
  end
end
