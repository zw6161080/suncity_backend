class AddRegionToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :jobs, :region, :string
  end
end
