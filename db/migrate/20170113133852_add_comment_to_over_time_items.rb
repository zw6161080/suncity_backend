class AddCommentToOverTimeItems < ActiveRecord::Migration[5.0]
  def change
    add_column :over_time_items, :comment, :text
  end
end
