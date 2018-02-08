class AddColumnToLentTemporarilyApplies < ActiveRecord::Migration[5.0]
  def change
    add_column :lent_temporarily_applies, :salary_calculation, :string
  end
end
