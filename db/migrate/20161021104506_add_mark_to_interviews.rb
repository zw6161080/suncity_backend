class AddMarkToInterviews < ActiveRecord::Migration[5.0]
  def change
    add_column :interviews, :mark, :string
  end
end
