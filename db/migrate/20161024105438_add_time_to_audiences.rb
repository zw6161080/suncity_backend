class AddTimeToAudiences < ActiveRecord::Migration[5.0]
  def change
    add_column :audiences, :time, :string
  end
end
