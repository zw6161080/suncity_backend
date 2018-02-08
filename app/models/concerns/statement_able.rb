module StatementAble

  # 引入該Module的報表Model需要做以下配置：
  # 1. 在config/predefined/statements/:table_name.yml中定義所有的columns
  # 2. 在config/locales/models/statement_columns/:table_name 下定義所有columns的key對應的I18N顯示名稱
  # 3. 對於此Module不能支持的key的查詢，需要在Model中定義 scope by_:key 的實現
  # 4. 在serializers/下定義報表列對應的Serializer
  # 5. 在相應Controller中，include StatementActions，並在對應resources的router中，
  #    增加collections路由 `columns`和`options`

  extend ActiveSupport::Concern

  included do
    scope :by_employee_name, -> (name) {
      where('users.chinese_name = :name OR users.english_name = :name', name: name)
    }

    scope :order_employee_name, -> (sort_direction) {
      order("users.#{select_language} #{sort_direction.first}")
    }
  end

  class_methods do
    def statement_columns(special_table_name = nil, params_id = nil)
      client_attributes = Config
                            .get('report_column_client_attributes')
                            .fetch('attributes', [])
      statement_columns_base(special_table_name, params_id).as_json.map { |col| col.slice(*client_attributes) }
    end

    def statement_columns_base(special_table_name = nil, params_id = nil)
      statement_field_columns = Config
                                  .get('statements')
                                  .fetch((special_table_name||self.table_name), { 'columns' => [] })['columns']
      columns_array = statement_field_columns.map do |column|
        key = column['key']
        column['data_index'] = column['data_index'].presence || key
        scope = [:statement_columns, (special_table_name || self.table_name).to_sym]
        if column['option']
          if column['options_select_key']
            column['option'] = Config.get('selects').dig(column['options_select_key'], 'options')
          end
        end
        column_names = {
          'chinese_name' => I18n.t(key, locale: 'zh-HK', scope: scope, default: ''),
          'english_name' => I18n.t(key, locale: 'en', scope: scope, default: ''),
          'simple_chinese_name' => I18n.t(key, locale: 'zh-CN', scope: scope, default: '')
        }

        column['children'] = column['children'].map do |hash|
          key = hash['key']
          hash['data_index'] = hash['data_index'].presence || key
          scope = [:statement_columns, (special_table_name || self.table_name).to_sym]
          children_column_names = {
              'chinese_name' => I18n.t(key, locale: 'zh-HK', scope: scope, default: ''),
              'english_name' => I18n.t(key, locale: 'en', scope: scope, default: ''),
              'simple_chinese_name' => I18n.t(key, locale: 'zh-CN', scope: scope, default: '')
          }
          hash.merge(children_column_names)
        end if column['children']
        column.merge(column_names)
      end
      extra_columns_options(params_id).each do|key, value|
        columns_array = columns_array.send( key, *value)
      end if extra_columns_options(params_id).is_a? Hash
      columns_array
    end

    def extra_columns_options(params_id)
      {}
    end

    def extra_query_params
      # 在Model中Override該方法，提供需要額外支持的搜索參數, eg:
      # [ { key: 'day_example', search_type: 'day_range' }, { key: 'value_example' } ]
      []
    end

    def query_columns(special_table_name = nil, params_id = nil)
      statement_columns_base(special_table_name, params_id).concat(extra_query_params.map { |param| param.stringify_keys })
    end
    def query(queries:, sort_column: nil, sort_direction: :desc, page: nil, per_page: 20, path_param: nil, special_table_name: nil)
      q = base_query(queries, path_param, special_table_name)
      unless sort_column.nil?
        q = decorate_ordered_query(q, sort_column, sort_direction, special_table_name, path_param)
      end
      unless page.nil?
        q = q.page.page(page).per(per_page)
      end
      q
    end

    def extra_joined_association_names
      [] # 留給include該model的累覆蓋，用來添加查詢額外需要join的model
    end

    def joined_query(param_id = nil)
      self.left_outer_joins(
        [
          {
            user: [:department, :location, :position, :profile]
          }
        ].concat(extra_joined_association_names)
      )
    end

    def default_query_decorator(query, attr, value)
      table_name = attr.split('.')[-2]  || self.table_name
      table_name = table_name.pluralize
      attr = attr.split('.')[-1]
      query.where(table_name => {attr => value})
    end

    def base_query(queries, path_param, special_table_name)
      q = joined_query(path_param)
      columns = query_columns(special_table_name, path_param).as_json.map do |col|
        [col['key'], col]
      end.to_h
      queries.each do |key, value|
        q = single_query(q, key, value, columns)
      end
      q
    end

    def single_query(q, key, value, columns)
      scope_sym = "by_#{key}".to_sym
      if q.respond_to?(scope_sym)
        q = q.send(scope_sym, value)
        return q
      end

      col = columns[key]
      if col.nil? && self.column_names.include?(key)
        q = q.where(key => value)
        return q
      end

      attr = col['search_attribute'].presence || key
      search_type = col['search_type']
      if attr == 'option_id'
        q = decorate_choice_question_query(q, value)
      elsif attr == 'score'
        q = decorate_matrix_single_choice_question_query(q, col['key'], value)
      elsif attr == 'train_class_id'
        q = decorate_train_class_query(q, value)
      elsif attr =~ /^user\.(\w+)$/
        q = decorate_user_attribute_query(q, $1, value)
      elsif attr =~ /^user\.profile\.(\w+)\.(\w+)$/ && search_type == 'date'
        q = decorate_profile_attribute_query_date(q, $1, $2, value)
      elsif attr =~ /^user\.profile\.(\w+)\.(\w+)$/
        q = decorate_profile_attribute_query(q, $1, $2, value)
      elsif search_type == 'date'
        q = decorate_date_query(q, attr, value)
      elsif search_type == 'year_range'
        q = decorate_year_range_query(q, attr, value)
      elsif search_type == 'month_range'
        q = decorate_month_range_query(q, attr, value)
      elsif search_type == 'day_range'
        q = decorate_day_range_query(q, attr, value)
      elsif search_type == 'decimal_range'
        q = decorate_decimal_range_query(q, attr, value)
      elsif search_type == 'number_range'
        q = decorate_number_range_query(q, attr, value)
      else
        q = default_query_decorator(q, attr, value)
      end
    end

    def options(special_table_name = nil, params_id = nil)
      selects = Config.get('selects')
      statement_columns_base(special_table_name, params_id).as_json.map do |col|
        options_type = col['options_type']
        if options_type == 'options' && !col['options_action'].nil?
          [col['key'], {
            options_type: options_type,
            options: col['option_id'] ? self.send(col['options_action'], col['option_id']) : (params_id ? self.send(col['options_action'], params_id) : self.send(col['options_action']))
          }]
        elsif options_type == 'api'
          [col['key'], {
            options_type: options_type,
            options: col['options_endpoint']
          }]
        elsif options_type == 'predefined'
          [col['key'], {
            options_type: options_type,
            options: col['options_predefined']
          }]
        elsif options_type == 'selects'
          [col['key'], {
            options_type: 'predefined',
            options: selects.dig(col['options_select_key'], 'options')
          }]
        end
      end.compact.to_h.deep_symbolize_keys
    end

    def company_name_options
      keys = self.joins(:user).select('users.company_name').map{|item| item['company_name']}
      Config.get_option_from_selects('company_name', keys)
    end

    def contribution_options
      column = 'contribution_item'
      keys = self.select(column).map{|item| item[column]}
      Config.get_option_from_selects(column,keys)
    end

    def resigned_reason_options
      Config.get_all_option_from_selects('resigned_reason')
    end

    def national_options
      keys = self.joins(user: :profile).select("profiles.data -> 'personal_information' -> 'field_values' ->> 'national' as national").map{|item| item['national']}
      Config.get_option_from_selects('nationality', keys)
    end

    def gender_options
      Config.get_all_option_from_selects('gender')
    end

    def grade_options
      keys = self.joins(:user).select('users.grade').map{|item| item['grade']}
      Config.get_option_from_selects('grade', keys)
    end

    def department_options
      Department.where(id: self.joins(:user).select('users.department_id'))
    end

    def location_options
      Location.where(id: self.joins(:user).select('users.location_id'))
    end

    def position_options
      Position.where(id: self.joins(:user).select('users.position_id'))
    end

    def year_month_options
      self.select(:year_month).distinct.order(:year_month).map do |record|
        {
          key: record.year_month,
          chinese_name: I18n.l(record.year_month, format: '%Y/%m', locale: :'zh-CN'),
          english_name_: I18n.l(record.year_month, format: '%Y/%m', locale: :'zh-HK'),
          simple_chinese_name: I18n.l(record.year_month, format: '%Y/%m', locale: :'en')
        }
      end
    end

    def decorate_ordered_query(q, sort_column, sort_direction, special_table_name = nil, params_id = nil)
      columns = statement_columns_base(special_table_name, params_id).as_json.map do |col|
        [col['key'], col]
      end.to_h
      #进行默认排序
      if sort_column == :created_at && q.respond_to?(:order_default)
        q = q.send(:order_default)
        return q
      end

      if q.column_names.include? sort_column.to_s
        return q.order(sort_column => sort_direction)
      end

      col = columns[sort_column.to_s]
      return q if col.nil?

      attr = col['search_attribute'].presence || col['key']
      scope_sym = "order_#{attr}".to_sym
      if q.respond_to?(scope_sym)
        q = q.send(scope_sym, [sort_direction, col['key']])
        return q
      end

      if attr =~ /^user\.(\w+)$/
        q.order("users.#{$1} #{sort_direction}")
      elsif attr =~ /^user\.profile\.(\w+)\.(\w+)$/
        field = "'{#{$1}, field_values, #{$2}}'"
        q.order("profiles.data #>> #{field} #{sort_direction}")
      elsif attr == 'career_entry_date'
        q.order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{sort_direction}")
      else
        table_name = attr.split('.')[-2]  || self.table_name
        table_name = table_name.pluralize
        attr = attr.split('.')[-1]
        q.order("#{table_name}.#{attr} #{sort_direction}")
      end
    end

    def common_decorate_range_query(q, attr, range_begin, range_end)
      table_name = attr.split('.')[-2]  || self.table_name
      table_name = table_name.pluralize
      attr = attr.split('.')[-1]
      if range_begin.nil? && range_end
        q.where("#{table_name}.#{attr} <= ?", range_end)
      elsif range_begin && range_end.nil?
        q.where("#{table_name}.#{attr} >= ?", range_begin)
      elsif range_begin && range_end
        date_range = range_begin..range_end
        q.where("#{table_name}.#{attr}" => date_range)
      else
        q
      end
    end

    def decorate_date_query(q, attr, value)
      table_name = attr.split('.')[-2]  || self.table_name
      table_name = table_name.pluralize
      table = table_name.classify.constantize
      if table.type_for_attribute(attr.split('.')[-1]).type == :date
        begin_date = (Time.zone.parse(value['begin']).to_date rescue nil)
        end_date = (Time.zone.parse(value['end']).to_date rescue nil)
      else
        begin_date = (Time.zone.parse(value['begin']) rescue nil)
        end_date = (Time.zone.parse(value['end']) rescue nil)
      end
      common_decorate_range_query(q, attr, begin_date, end_date)
    end

    def decorate_year_range_query(q, attr, value)
      begin_date = (Time.zone.parse(value['begin']).beginning_of_year rescue nil)
      end_date = (Time.zone.parse(value['end']).end_of_year rescue nil)
      common_decorate_range_query(q, attr, begin_date, end_date)
    end

    def decorate_month_range_query(q, attr, value)
      begin_date = (Time.zone.parse(value['begin']).beginning_of_month rescue nil)
      end_date = (Time.zone.parse(value['end']).end_of_month rescue nil)
      common_decorate_range_query(q, attr, begin_date, end_date)
    end

    def decorate_day_range_query(q, attr, value)
      begin_date = (Time.zone.parse(value['begin']).beginning_of_day rescue nil)
      end_date = (Time.zone.parse(value['end']).end_of_day rescue nil)
      common_decorate_range_query(q, attr, begin_date, end_date)
    end

    def decorate_decimal_range_query(q, attr, value)
      range_begin = (BigDecimal(value['begin']) rescue nil)
      range_end = (BigDecimal(value['end']) rescue nil)
      common_decorate_range_query(q, attr, range_begin, range_end)
    end

    def decorate_number_range_query(q, attr, value)
      common_decorate_range_query(q, attr, value['begin'], value['end'])
    end

    def decorate_user_attribute_query(q, attr, value)
      q.where(users: { attr => value })
    end

    def decorate_profile_attribute_query(q, section, field, value)
      q.where('profiles.data #>> :field = :value',
              field: "{#{section}, field_values, #{field}}",
              value: value)
    end

    def decorate_profile_attribute_query_date(q, section, field, value)
      begin_date = (Time.zone.parse(value['begin']) rescue nil)
      end_date = (Time.zone.parse(value['end']) rescue nil)
      if begin_date && end_date
        q.where('profiles.data #>> :field >= :value',
                field: "{#{section}, field_values, #{field}}",
                value: begin_date)
          .where('profiles.data #>> :field <= :value',
                 field: "{#{section}, field_values, #{field}}",
                 value: end_date)
      elsif begin_date && end_date.nil?
        q.where('profiles.data #>> :field >= :value',
                field: "{#{section}, field_values, #{field}}",
                value: begin_date)
      elsif begin_date.nil? && end_date
        q.where('profiles.data #>> :field <= :value',
                field: "{#{section}, field_values, #{field}}",
                value: end_date)
      else
        q
      end
    end

    def decorate_choice_question_query(q, value)
      ids = q.joins(questionnaire: :choice_questions).where("choice_questions.answer = array["+ value.map{|item| "#{item}"}.join(',') +"]" ).select(:id)
      q.where(id: ids).distinct(:id)
    end

    def decorate_matrix_single_choice_question_query(q, table_id, value)
      order_no, item_no = table_id.split('.').map(&:to_i)
      ids = q.joins(questionnaire: {matrix_single_choice_questions: :matrix_single_choice_items}).where("matrix_single_choice_questions.order_no = :order_no AND matrix_single_choice_items.item_no = :item_no AND matrix_single_choice_items.score IN ("+value.map{|item| "#{item}"}.join(',') + ")", order_no: order_no, item_no: item_no).select(:id)
      q.where(id: ids).distinct(:id)
    end

    def decorate_train_class_query(q, value)
      ids = q.joins(:train_classes).where("train_classes.id IN ("+value.map{|item| "#{item}"}.join(',') + ")").select(:id)
      q.where(id: ids).distinct(:id)
    end

  end

end