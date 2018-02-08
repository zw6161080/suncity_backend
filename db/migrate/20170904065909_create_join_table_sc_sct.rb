class CreateJoinTableScSct < ActiveRecord::Migration[5.0]
  def change
    create_join_table :salary_columns, :salary_column_templates do |t|
      t.index [:salary_column_id, :salary_column_template_id], name: 'index_on_join_table_sc_sct'
    end
  end
end
