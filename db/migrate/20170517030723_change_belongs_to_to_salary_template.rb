class ChangeBelongsToToSalaryTemplate < ActiveRecord::Migration[5.0]
  def change
    change_column_default  :salary_templates, :belongs_to, from: nil, to: {}
  end
end
