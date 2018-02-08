class ChangeColumnsToLentTemporarilyApplies < ActiveRecord::Migration[5.0]
  def change
    remove_column :lent_temporarily_applies, :creator_id, :integer
    add_column :lent_temporarily_applies, :job_transfer_id, :integer
  end
end
