class AddColumnToPassTrials < ActiveRecord::Migration[5.0]
  def change
    add_column :pass_trials, :salary_calculation, :string
  end
end
