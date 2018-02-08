class AddTerminationCompensationToDimission < ActiveRecord::Migration[5.0]
  def change
    add_column :dimissions, :termination_compensation, :integer
  end
end
