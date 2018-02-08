class AddColumnToAnnualAwardReport < ActiveRecord::Migration[5.0]
  def change
    add_column :annual_award_reports, :status, :string
  end
end
