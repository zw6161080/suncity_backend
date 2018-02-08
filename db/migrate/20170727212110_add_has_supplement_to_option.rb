class AddHasSupplementToOption < ActiveRecord::Migration[5.0]
  def change
    add_column :options, :has_supplement, :boolean
  end
end
