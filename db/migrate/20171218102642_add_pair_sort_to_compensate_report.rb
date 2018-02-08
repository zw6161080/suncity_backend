class AddPairSortToCompensateReport < ActiveRecord::Migration[5.0]
  def change
    add_column :compensate_reports, :pair_sort_key, :string
  end
end
