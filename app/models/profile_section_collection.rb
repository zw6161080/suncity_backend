# coding: utf-8
class ProfileSectionCollection
  include ProfileEnumerable

  def initialize(items)
    @items = items
  end

  def enumerable_item
    @items
  end

  def items
    @items
  end

  def supervisor=(supervisor)
    @supervisor = supervisor
    self.each do |item|
      item.supervisor = supervisor
    end
  end

  # find section from section collections
  def find(key)
    items.find do |item|
      item.key == key
    end
  end

  # edit field, params = { section_key:, field:, new_value: }
  def edit_field(params)
    # find section by key
    section = self.find(params[:section_key])
    # dispatch edit action to section
    section.send('edit_field', params)
  end

  # add row to table section, params = { section_key:, new_row: {} }
  def add_row(params)
    # find section by key
    section = self.find(params[:section_key])
    section.send('add_row', params)
  end

  # edit row, params = { section_key:, row_id:, fields: { field: value } }
  def edit_row_fields(params)
    section = self.find(params[:section_key])
    section.send('edit_row_fields', params)
  end

  # remove row, params = { section_key:, row_id: }
  def remove_row(params)
    section = self.find(params[:section_key])
    section.send('remove_row', params)
  end

  def as_json(*args)
    items.as_json
  end

  def serializable_hash(*args)
    self.as_json(*args)
  end

  # 获取所有section的值
  def to_values
    items.inject({}) do |hash, section|
      hash_data = section.to_value_data
      hash[hash_data['key']] = hash_data.except('key')
      hash
    end
  end

  # fill stateful value to section
  def merge_params(params)
    params = form_params(params)
    self.each do |section|
      if params.key?(section.key)
        section.merge_params(params[section.key])
      end
    end
  end

  def form_params(params)
    if params.kind_of?(Array)
      array_to_hash(params).to_h
    else
      params
    end
  end

  #change array to hash
  def array_to_hash(params)
    params.map do |item|
      [
          item['key'],
          item
      ]
    end
  end

  def region
    items.first.initialized_options[:region]
  end

  def on_save
    items.each(&:on_save)
  end
end
