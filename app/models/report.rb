# == Schema Information
#
# Table name: reports
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  simple_chinese_name :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  key                 :string
#  url_type            :string
#  rows_url            :string
#  columns_url         :string
#  options_url         :string
#

class Report < ApplicationRecord
  has_many :report_columns

  enum url_type: { by_id: 'by_id', by_setting: 'by_setting' }

  def self.load_predefined
    report_config = Config.get('reports')
    report_config.each do |key, value|
      self.create_from_config(value.merge({ 'key' => key}))
    end
  end

  def self.create_from_config(report_config)
    ActiveRecord::Base.transaction do
      report = self.find_or_create_by(key: report_config['key'])
      report.update(report_config.except('columns'))

      if report.url_type == 'by_id'
        report_columns_config = Config.get('report_columns')
        report_config['columns'].each do |key|
          report
            .report_columns
            .find_or_create_by(key: key)
            .update(report_columns_config[key])
        end
        report.save
      end

      report
    end
  end

  def columns
    report_columns.map do |col|
      columns_attributes = Config
                             .get('report_column_client_attributes')
                             .fetch('attributes', [])
      col.as_json(only: columns_attributes).merge({ options: col.options })
    end
  end

  def query(request_queries:, order_key: nil, order: :desc, page: 1, page_per: 20)
    queries = preprocess_queries(request_queries)
    models = collect_models

    if models.count == 1
      model = models.first
      if model == Profile
        return query_profile(
          queries: queries,
          order_key: order_key,
          order: order,
          page: page,
          page_per: page_per,
        )
      else
        return query_single_model(
          model:model,
          queries: queries,
          order_key: order_key,
          order: order,
          page: page,
          page_per: page_per,
        )
      end
    end

    other_models = models - [User, Profile]
    if other_models.count == 0
      return query_user_profile(
        queries: queries,
        order_key: order_key,
        order: order,
        page: page,
        page_per: page_per,
      )
    end

    query_user_profile_and_models(
      other_models: other_models,
      queries: queries,
      order_key: order_key,
      order: order,
      page: page,
      page_per: page_per,
    )
  end

  private

  def query_single_model(model:, queries:, order_key:, order:, page:, page_per:)
    # query conditions
    query = model.where(queries).select(selectors)

    # sort conditions
    sort_col = report_columns.find { |c| c.key == order_key }
    unless sort_col.nil?
      sort_table_name = sort_col.source_model.classify.safe_constantize.table_name
      sort_column_name = [sort_table_name, sort_col.source_attribute].join('.')
      query = query.order(sort_column_name => order)
    end

    # paging
    query.page.page(page).per(page_per)
  end

  def query_profile(queries:, order_key:, order:, page:, page_per:)
    # TODO: handle profile

  end

  def query_user_profile(queries:, order_key:, order:, page:, page_per:)
    # TODO: handle profile

  end

  def query_user_profile_and_models(other_models:, queries:, order_key:, order:, page:, page_per:)
    # query conditions
    query = user_profile_models_joined_query(other_models: other_models).where(queries).select(selectors)

    # sort conditions
    sort_col = report_columns.find { |c| c.key.to_s == order_key.to_s }
    unless sort_col.nil?
      sort_table_name = sort_col.source_model.classify.safe_constantize.table_name
      sort_column_name = [sort_table_name, sort_col.source_attribute].join('.')
      query = query.order("#{sort_column_name} #{order}")
    end

    # paging
    query.page.page(page).per(page_per)
  end

  def user_profile_models_joined_query(other_models:)
    join_conditions = collect_conditions(other_models)

    join_pivot = nil
    join_conditions.each do |table_name, conditions|
      next if conditions['join_attribute'].nil?
      join_pivot = [table_name, conditions['join_attribute']].join('.')
    end

    join_sqls = join_conditions.map do |table_name, conditions|
      model_to_user_foreign_key = conditions['model_to_user_foreign_key']
      user_to_model_foreign_key = conditions['user_to_model_foreign_key']

      if model_to_user_foreign_key.present?
        user_join_attribute = 'users.id'
        model_join_attribute = [table_name, model_to_user_foreign_key].join('.')
      elsif user_to_model_foreign_key.present?
        user_join_attribute = ['users', user_to_model_foreign_key].join('.')
        model_join_attribute = [table_name, 'id'].join('.')
      else
        raise LogicError, 'Can not join tables for report without association '
      end

      join_attribute = conditions['join_attribute']

      if join_attribute.nil?
        "LEFT OUTER JOIN #{table_name} ON #{user_join_attribute} = #{model_join_attribute}"
      else
        join_statement = [table_name, join_attribute].join('.')
        if join_statement == join_pivot
          "LEFT OUTER JOIN #{table_name} ON #{user_join_attribute} = #{model_join_attribute}"
        else
          "LEFT OUTER JOIN #{table_name} ON #{user_join_attribute} = #{model_join_attribute} and #{join_pivot} = #{join_statement}"
        end
      end
    end

    # 得到所有table的join的集合
    User.joins(join_sqls.join(' '))
  end

  def selectors
    report_columns.map do |c|
      table_name = c.source_model.classify.safe_constantize.table_name
      column_name = [table_name, c.source_attribute].join('.')
      "#{column_name} AS #{c.data_index}"
    end
  end

  def collect_models
    report_columns
      .map { |c| c.source_model.classify.safe_constantize }
      .compact
      .uniq
  end

  def collect_conditions(models)
    models_config = Config.get('report_models_config')
    null_config = {
      'model_to_user_foreign_key' => nil,
      'user_to_model_foreign_key' => nil,
      'join_type' => nil,
      'join_attribute' => nil,
    }
    models.map { |m| [m.table_name, models_config.fetch(m.name, null_config)] }.to_h
  end

  def preprocess_queries(queries)
    queries.as_json
      .map do |key, value|
        col = report_columns.find { |c| c.key == key }
        next nil if col.nil?

        table_name = col.source_model.classify.safe_constantize.table_name
        attribute_name = [table_name, col.source_attribute].join('.')

        if %w(string_value select_value bool_value obj_value).include? col.value_type
          [attribute_name, value]
        elsif 'date_value' == col.value_type
          date_begin = Time.zone.parse(value['begin']) rescue nil
          date_end = Time.zone.parse(value['end']) rescue nil
          date_begin && date_end ? [attribute_name, date_begin..date_end] : nil
        else
          nil
        end
      end
      .compact
      .to_h
  end
end
