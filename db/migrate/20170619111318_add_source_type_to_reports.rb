class AddSourceTypeToReports < ActiveRecord::Migration[5.0]
  def change
    add_column :reports, :url_type, :string
    add_column :reports, :rows_url, :string
    add_column :reports, :columns_url, :string
  end
end
