class AddOrderToApplicantPositions < ActiveRecord::Migration[5.0]
  def change
    add_column :applicant_positions, :order, :string
    add_index :applicant_positions, :order
  end
end
