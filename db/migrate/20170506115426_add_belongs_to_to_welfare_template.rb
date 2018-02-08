class AddBelongsToToWelfareTemplate < ActiveRecord::Migration[5.0]
  def change
    add_column :welfare_templates, :belongs_to , :jsonb , default: {}
  end
end
