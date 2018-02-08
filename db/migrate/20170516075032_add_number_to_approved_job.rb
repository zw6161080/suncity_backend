class AddNumberToApprovedJob < ActiveRecord::Migration[5.0]
  def change
    add_column :approved_jobs, :number, :integer
  end
end
