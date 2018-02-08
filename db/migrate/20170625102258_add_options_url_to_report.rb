class AddOptionsUrlToReport < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :options_url, :string
  end
end
