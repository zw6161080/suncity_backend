class CreateReportColumns < ActiveRecord::Migration[5.0]
  def change
    create_table :report_columns do |t|
      t.references :report, foreign_key: true
      t.string :key
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :value_type
      t.string :data_index
      t.string :search_type
      t.boolean :sorter

      t.string :options_type # api / predefined
      t.jsonb :options_predefined
      t.string :options_endpoint

      t.string :source_data_type # model類型，或者profile類型
      # source_date_type是model的時候，以下字段啓用
      t.string :source_model
      t.string :source_model_user_association_attribute
      t.string :join_attribute
      t.string :source_attribute

      t.timestamps
    end
  end
end
