class AddColumnToAppraisals < ActiveRecord::Migration[5.0]
  def change
    add_column :appraisals, :group_situation, :jsonb
  end
end
